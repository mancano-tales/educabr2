"""Base de dados do NEWS.md derivada do git: uma linha por entrada, ligada ao commit que a criou.

O NEWS.md continua sendo o registro narrativo; esta base não o substitui. O que é da máquina (hash,
data e hora exatas, arquivos alterados, mensagem) vem do git e não depende de quem escreveu a
entrada. O que é declarado à mão (agente, mensagem, arquivos) aparece ao lado, com uma coluna
dizendo se confere.

Uso (da raiz de qualquer repo com NEWS.md; só biblioteca padrão):
  python tools/news_db.py                         # resumo de consistência
  python tools/news_db.py --saida news.sqlite     # base SQLite (tabelas: entradas, arquivos; hash_news e fragment_id)
  python tools/news_db.py --saida news.csv        # CSV (uma linha por entrada)
  python tools/news_db.py --saida news.json       # JSON

Consultas de exemplo no SQLite:
  SELECT harness, count(*) FROM entradas GROUP BY harness;
  SELECT data_commit, titulo FROM entradas WHERE titulo LIKE '%issue%' ORDER BY data_commit;
  SELECT e.titulo FROM entradas e JOIN arquivos a USING(hash) WHERE a.caminho LIKE 'AGENTS.md';

A saída é derivada e se regenera a qualquer momento: não versionar.
"""
from __future__ import annotations

import csv
import difflib
import json
import re
import sqlite3
import subprocess
import sys
from pathlib import Path

from news_fragments import find_source_commit

ARQ = "NEWS.md"
SEP = "\x1f"
FRAGMENT_MARKER = re.compile(r"\s*<!-- NEWS-FRAGMENT:([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}) -->$")


def git(*args: str) -> str:
    r = subprocess.run(["git", *args], capture_output=True, text=True, encoding="utf-8", errors="replace")
    if r.returncode != 0:
        raise SystemExit(f"git {' '.join(args[:3])}: {r.stderr.strip()}")
    return r.stdout


def news_em(rev: str) -> str:
    r = subprocess.run(["git", "show", f"{rev}:{ARQ}"], capture_output=True, text=True,
                       encoding="utf-8", errors="replace")
    return r.stdout.replace("\r\n", "\n") if r.returncode == 0 else ""


def entradas(texto: str) -> dict[str, str]:
    """cabeçalho (sem '## ') -> corpo. Entradas repetidas com o mesmo cabeçalho ficam com a primeira."""
    saida: dict[str, str] = {}
    for bloco in re.split(r"(?m)^## ", texto)[1:]:
        cab, _, corpo = bloco.partition("\n")
        saida.setdefault(cab.strip(), corpo.strip())
    return saida


def parecido(a: str, b: str) -> bool:
    if a == b:
        return True
    if abs(len(a) - len(b)) > 0.2 * max(len(a), len(b), 1):
        return False
    return difflib.SequenceMatcher(None, a[:3000], b[:3000]).quick_ratio() > 0.9 and \
        difflib.SequenceMatcher(None, a[:3000], b[:3000]).ratio() > 0.9


def campo(corpo: str, nome: str) -> str | None:
    m = re.search(rf"\*\*{nome}\*\*:\s*(.+?)\s*$", corpo, flags=re.M)
    return m.group(1).strip().strip('"“”`').strip() if m else None


def harness(agente: str | None) -> str | None:
    if not agente:
        return None
    a = agente.lower()
    for chave, nome in [("claude code", "Claude Code"), ("coralcastle", "Claude Code"), ("codex", "Codex"),
                        ("cobaltcanyon", "Codex"), ("gpt", "Codex"), ("antigravity", "Antigravity"),
                        ("gemini", "Antigravity"), ("cursor", "Cursor"), ("claude", "Claude (sem harness)")]:
        if chave in a:
            return nome
    return "outro"


def construir() -> list[dict]:
    log = git("log", "--reverse", f"--format=%H{SEP}%P{SEP}%aI{SEP}%an{SEP}%s", "--", ARQ)
    registros: dict[str, dict] = {}      # cabeçalho atual -> registro
    for linha in filter(None, log.splitlines()):
        h, pais, data, autor, msg = linha.split(SEP)
        pais = pais.split()
        atual = entradas(news_em(h))
        antes = entradas(news_em(pais[0])) if pais else {}
        # Num merge, o que veio do outro ramo não é autoria deste commit.
        outro = set()
        for p in pais[1:]:
            outro |= set(entradas(news_em(p)))
        novas = [c for c in atual if c not in antes and c not in outro]
        sumidas = [c for c in antes if c not in atual]
        arquivos = [a for a in git("diff", "--name-only", pais[0], h).splitlines()] if pais else \
            git("show", "--name-only", "--format=", h).splitlines()
        for cab in novas:
            corpo = atual[cab]
            marker = FRAGMENT_MARKER.search(cab)
            fragment_id = marker.group(1) if marker else None
            cabecalho = FRAGMENT_MARKER.sub("", cab).strip()
            source_hash = h
            source_data, source_author, source_msg = data, autor, msg
            source_parents, source_files = pais, arquivos
            if fragment_id:
                fragment_path = f"newsfragments/{fragment_id}.md"
                source_hash = find_source_commit(Path.cwd(), fragment_path)
                if not source_hash:
                    raise SystemExit(f"fragmento {fragment_path} não tem commit de origem acessível; use histórico Git completo")
                if source_hash != h:
                    info = git("show", "-s", f"--format=%H{SEP}%P{SEP}%aI{SEP}%an{SEP}%s", source_hash).strip().split(SEP, 4)
                    if len(info) != 5:
                        raise SystemExit(f"não foi possível ler o commit fonte do fragmento {fragment_id}")
                    _, parents_text, source_data, source_author, source_msg = info
                    source_parents = parents_text.split()
                    source_files = (git("diff", "--name-only", source_parents[0], source_hash) if source_parents else
                                    git("diff-tree", "--root", "--no-commit-id", "--name-only", "-r", source_hash)).splitlines()
            # A fragment ID is the stable identity if a generated heading is corrected later.
            existing_key = next((key for key, value in registros.items()
                                 if fragment_id and value.get("fragment_id") == fragment_id), None)
            if existing_key is not None:
                reg = registros.pop(existing_key)
                reg["edicoes"].append({"hash": h, "data": data, "cabecalho_anterior": reg["cabecalho"]})
                reg["cabecalho"], reg["titulo"], reg["texto"] = cabecalho, cabecalho, corpo
                reg["hash_news"] = h
                registros[cab] = reg
                sumidas[:] = [item for item in sumidas if item != existing_key]
                continue
            # Cabeçalho corrigido (ex.: horário) com corpo igual: é edição de uma entrada existente.
            origem = next((s for s in sumidas if parecido(antes[s], corpo)), None) if not fragment_id else None
            if origem and origem in registros:
                reg = registros.pop(origem)
                reg["edicoes"].append({"hash": h, "data": data, "cabecalho_anterior": origem})
                reg["cabecalho"], reg["texto"] = cabecalho, corpo
                registros[cab] = reg
                sumidas.remove(origem)
                continue
            data_cab = re.match(r"(\d{4}-\d{2}-\d{2})(?: (\d{2}:\d{2}))?", cabecalho)
            titulo = re.sub(r"^\d{4}-\d{2}-\d{2}(?: \d{2}:\d{2})?\s*[—–-]\s*", "", cabecalho)
            agente = campo(corpo, "Agente")
            declarada = campo(corpo, "Mensagem do Commit")
            registros[cab] = {
                "hash": source_hash, "hash_news": h if fragment_id else source_hash,
                "fragment_id": fragment_id, "fragment_path": f"newsfragments/{fragment_id}.md" if fragment_id else None,
                "data_commit": source_data, "autor_git": source_author, "mensagem_commit": source_msg,
                "cabecalho": cabecalho, "titulo": titulo,
                "data_cabecalho": data_cab.group(1) if data_cab else None,
                "hora_cabecalho": data_cab.group(2) if data_cab else None,
                "agente": agente, "harness": harness(agente),
                "mensagem_declarada": declarada,
                "mensagem_confere": (declarada == source_msg) if declarada else None,
                "data_confere": (data_cab.group(1) == source_data[:10]) if data_cab else None,
                "arquivos_commit": source_files, "arquivos_declarados": campo(corpo, "Arquivos afetados"),
                "texto": corpo, "edicoes": [], "merge": len(source_parents) > 1,
            }
    hoje = entradas(news_em("HEAD"))
    for chave, reg in registros.items():
        reg["no_news_atual"] = chave in hoje  # False = apagada ou reescrita por inteiro depois
    # Entradas que existem hoje mas não foram atribuídas (ex.: escritas antes do NEWS.md entrar no git).
    for cab, corpo in hoje.items():
        if cab not in registros:
            registros[cab] = {"hash": None, "cabecalho": cab, "titulo": cab, "texto": corpo, "edicoes": [],
                              "sem_commit": True, "no_news_atual": True}
    return list(registros.values())


def resumo(regs: list[dict]) -> None:
    com = [r for r in regs if r.get("hash")]
    n = len(com)
    total_commits = int(git("rev-list", "--count", "HEAD").strip())
    commits_news = len({r["hash"] for r in com})
    decl = [r for r in com if r.get("mensagem_declarada")]
    conf = sum(1 for r in decl if r["mensagem_confere"])
    datas = [r for r in com if r.get("data_confere") is not None]
    dconf = sum(1 for r in datas if r["data_confere"])
    print(f"Entradas ligadas a um commit: {n} | sem commit identificável: {len(regs) - n}")
    print(f"Commits no repo: {total_commits} | commits que criaram entrada: {commits_news}")
    print(f"Mensagem declarada = mensagem real do commit: {conf}/{len(decl)}")
    print(f"Data do cabeçalho = dia do commit: {dconf}/{len(datas)}")
    print(f"Entradas com cabeçalho editado depois: {sum(1 for r in com if r['edicoes'])}")
    print(f"Entradas que existiram e não estão mais no NEWS.md: {sum(1 for r in com if not r.get('no_news_atual'))}")
    hs: dict[str, int] = {}
    for r in com:
        hs[r.get("harness") or "sem agente"] = hs.get(r.get("harness") or "sem agente", 0) + 1
    print("Por harness:", ", ".join(f"{k} {v}" for k, v in sorted(hs.items(), key=lambda x: -x[1])))


def gravar(regs: list[dict], destino: Path) -> None:
    if destino.suffix == ".json":
        destino.write_text(json.dumps(regs, ensure_ascii=False, indent=1), encoding="utf-8")
    elif destino.suffix == ".csv":
        cols = ["hash", "hash_news", "fragment_id", "fragment_path", "data_commit", "autor_git", "mensagem_commit",
                "titulo", "data_cabecalho", "hora_cabecalho", "agente", "harness", "mensagem_declarada",
                "mensagem_confere", "data_confere", "merge", "no_news_atual", "arquivos_commit",
                "arquivos_declarados", "edicoes", "texto"]
        with destino.open("w", newline="", encoding="utf-8") as f:
            w = csv.DictWriter(f, fieldnames=cols, extrasaction="ignore")
            w.writeheader()
            for r in regs:
                w.writerow({**r, "arquivos_commit": "; ".join(r.get("arquivos_commit") or []),
                            "edicoes": "; ".join(e["hash"][:7] for e in r.get("edicoes", []))})
    elif destino.suffix in {".sqlite", ".db"}:
        destino.unlink(missing_ok=True)
        con = sqlite3.connect(destino)
        con.execute("""CREATE TABLE entradas (hash TEXT, hash_news TEXT, fragment_id TEXT, fragment_path TEXT,
            data_commit TEXT, autor_git TEXT, mensagem_commit TEXT, titulo TEXT, cabecalho TEXT,
            data_cabecalho TEXT, hora_cabecalho TEXT, agente TEXT, harness TEXT, mensagem_declarada TEXT,
            mensagem_confere INTEGER, data_confere INTEGER, merge INTEGER, no_news_atual INTEGER,
            arquivos_declarados TEXT, edicoes TEXT, texto TEXT)""")
        con.execute("CREATE TABLE arquivos (hash TEXT, caminho TEXT)")
        for r in regs:
            con.execute("INSERT INTO entradas VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", (
                r.get("hash"), r.get("hash_news"), r.get("fragment_id"), r.get("fragment_path"),
                r.get("data_commit"), r.get("autor_git"), r.get("mensagem_commit"), r.get("titulo"),
                r.get("cabecalho"), r.get("data_cabecalho"), r.get("hora_cabecalho"), r.get("agente"), r.get("harness"),
                r.get("mensagem_declarada"), r.get("mensagem_confere"), r.get("data_confere"), r.get("merge"), r.get("no_news_atual"),
                r.get("arquivos_declarados"), json.dumps(r.get("edicoes", []), ensure_ascii=False), r.get("texto")))
        for h in {r["hash"] for r in regs if r.get("hash")}:
            r0 = next(r for r in regs if r.get("hash") == h)
            con.executemany("INSERT INTO arquivos VALUES (?,?)", [(h, a) for a in r0.get("arquivos_commit", [])])
        con.commit()
        con.close()
    else:
        raise SystemExit("formato não reconhecido: use .sqlite, .db, .csv ou .json")


def main(argv: list[str]) -> int:
    if not Path(ARQ).exists():
        raise SystemExit(f"rode da raiz de um repositório com {ARQ}")
    regs = construir()
    resumo(regs)
    if "--saida" in argv:
        destino = Path(argv[argv.index("--saida") + 1])
        gravar(regs, destino)
        print(f"Gravado: {destino} ({len(regs)} entradas)")
    return 0


if __name__ == "__main__":
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    sys.exit(main(sys.argv[1:]))
