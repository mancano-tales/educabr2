"""Liga cada plano de repo-governance/plan/ a uma issue do GitHub.

Regra e papéis: AGENTS.md (seção "Planos e issues") e
repo-governance/plan/2026-09-26_Plano_Issue_Por_Plano.md.

Uso (da raiz do hub ou de qualquer pasta dele; requer o `gh` autenticado):
  python tools/plano_issue.py criar <plano.md> [--dry-run]
  python tools/plano_issue.py verificar
  python tools/plano_issue.py fechar <plano.md> [--motivo "texto"]
  python tools/plano_issue.py hook          # lembrete para hooks PostToolUse (lê JSON do stdin)

Só biblioteca padrão. Não guarda segredo nenhum: a autenticação é a do `gh`.
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
# A pasta de planos varia entre os repos do ecossistema; a primeira que existir vale.
# Para forçar outra: variável de ambiente PLANO_ISSUE_PASTA (relativa à raiz do repo).
_CANDIDATAS = ["repo-governance/plan", "9-vers/plan", "0-governance/plan", "0-meta/plan", "plan"]


def _pasta_de_planos() -> Path:
    import os
    forcada = os.environ.get("PLANO_ISSUE_PASTA")
    if forcada:
        return RAIZ / forcada
    for c in _CANDIDATAS:
        if (RAIZ / c).is_dir():
            return RAIZ / c
    return RAIZ / _CANDIDATAS[0]


PASTA = _pasta_de_planos()
INDICE = PASTA / "README.md"
ATIVOS = {"ATIVO", "EM EXECUÇÃO"}
ETIQUETA = "plano"
IGNORAR = {"README.md", "2026-07-11_Plano_TEMPLATE.md"}


# ── Leitura do cabeçalho YAML (sem PyYAML: só os campos simples que usamos) ──────────
def ler(plano: Path) -> tuple[str, dict, list[str]]:
    texto = plano.read_text(encoding="utf-8")
    linhas = texto.splitlines(keepends=True)
    campos: dict = {"tarefas": []}
    if not linhas or linhas[0].strip() != "---":
        return texto, campos, linhas
    for i, l in enumerate(linhas[1:], start=1):
        s = l.rstrip("\r\n")
        if s.strip() == "---":
            campos["_fim"] = i
            break
        m = re.match(r"^(\w+):\s*(.*)$", s)
        if m and m.group(1) != "tarefas":  # "tarefas:" abre a lista; não sobrescrever
            chave, valor = m.group(1), m.group(2).split(" #")[0].strip().strip('"')
            campos[chave] = valor
        t = re.match(r'^\s*-\s*\{\s*desc:\s*"(.*?)",\s*status:\s*([^,}\s]+)', s)
        if t:
            campos["tarefas"].append((t.group(1), t.group(2)))
    return texto, campos, linhas


def issue_de(campos: dict) -> int | None:
    v = str(campos.get("issue", "")).strip().lstrip("#")
    return int(v) if v.isdigit() else None


def status_de(campos: dict) -> str:
    return str(campos.get("status", "")).strip().upper()


def rel(p: Path) -> str:
    return p.resolve().relative_to(RAIZ).as_posix()


def gh(*args: str, entrada: str | None = None) -> str:
    r = subprocess.run(["gh", *args], cwd=RAIZ, input=entrada, capture_output=True,
                       text=True, encoding="utf-8")
    if r.returncode != 0:
        raise SystemExit(f"gh {' '.join(args[:2])} falhou: {r.stderr.strip()}")
    return r.stdout.strip()


def repo() -> str:
    return gh("repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner")


# ── Escrita: issue: N no YAML e #N no índice ─────────────────────────────────────────
def gravar_issue(plano: Path, numero: int) -> None:
    texto, campos, linhas = ler(plano)
    fim = campos.get("_fim")
    if fim is None:
        raise SystemExit(f"{rel(plano)} não tem cabeçalho YAML; acrescente-o antes (ver template).")
    eol = "\r\n" if linhas[0].endswith("\r\n") else "\n"
    for i in range(1, fim):
        if re.match(r"^issue:", linhas[i]):
            linhas[i] = f"issue: {numero}{eol}"
            break
    else:
        pos = next((i + 1 for i in range(1, fim) if re.match(r"^status:", linhas[i])), fim)
        linhas.insert(pos, f"issue: {numero}{eol}")
    plano.write_text("".join(linhas), encoding="utf-8", newline="")


def marcar_indice(plano: Path, numero: int) -> bool:
    if not INDICE.exists():
        return False
    bruto = INDICE.read_text(encoding="utf-8")
    nome = plano.name
    saida, achou = [], False
    for linha in bruto.splitlines(keepends=True):
        if linha.startswith(f"| `{nome}`") and f"issue #{numero}" not in linha:
            partes = linha.rstrip("\r\n").split("|")
            if len(partes) > 3:
                partes[2] = f"{partes[2].rstrip()} · issue #{numero} "
                linha = "|".join(partes) + linha[len(linha.rstrip("\r\n")):]
                achou = True
        saida.append(linha)
    if achou:
        INDICE.write_text("".join(saida), encoding="utf-8", newline="")
    return achou


def corpo(plano: Path, campos: dict, nome_repo: str) -> str:
    caminho = rel(plano)
    pendentes = [d for d, s in campos["tarefas"] if s.lower() not in {"concluido", "concluído", "superado", "adiado"}]
    tarefas = "\n".join(f"- [ ] {d}" for d in pendentes[:12]) or "- (ver plano)"
    return f"""**Plano:** [`{caminho}`](https://github.com/{nome_repo}/blob/main/{caminho})
**Status do plano:** {campos.get('status', '?')} · criado {campos.get('criado', '?')}

## Resumo vivo
_Corpo atualizado a cada marco (estado, próximo passo, com quem está). Quem chega lê isto e os últimos comentários._

- **Estado:** {campos.get('status', '?')}
- **Próximo passo:** (preencher)
- **Com quem está:** (preencher)

### Tarefas em aberto no plano
{tarefas}

---
**Regras** (`AGENTS.md`, seção "Planos e issues"): a conversa entre agentes é aqui; **decisões e
aprovações só valem no arquivo do plano**. Aprovação em comentário não vale, porque todos os agentes
comentam com a conta do autor. Cabeçalho em todo comentário de agente: `kind:`, `sessao:`, `modelo:`, `esforco:`.
"""


# ── Comandos ─────────────────────────────────────────────────────────────────────────
def criar(plano: Path, dry: bool) -> int:
    _, campos, _ = ler(plano)
    n = issue_de(campos)
    if n:
        print(f"{rel(plano)} já tem a issue #{n}.")
        return 0
    titulo = campos.get("titulo") or plano.stem
    nome_repo = repo()
    texto = corpo(plano, campos, nome_repo)
    if dry:
        print(f"[dry-run] criaria em {nome_repo}: [plano] {titulo}\n\n{texto}")
        return 0
    subprocess.run(["gh", "label", "create", ETIQUETA, "--color", "1D76DB",
                    "--description", "Issue de coordenação de um plano de repo-governance/plan"],
                   cwd=RAIZ, capture_output=True, text=True)  # já existir não é erro
    with tempfile.NamedTemporaryFile("w", suffix=".md", delete=False, encoding="utf-8") as f:
        f.write(texto)
        tmp = f.name
    try:
        url = gh("issue", "create", "--title", f"[plano] {titulo}", "--label", ETIQUETA, "--body-file", tmp)
    finally:
        Path(tmp).unlink(missing_ok=True)
    numero = int(url.rstrip("/").rsplit("/", 1)[-1])
    gravar_issue(plano, numero)
    no_indice = marcar_indice(plano, numero)
    print(f"{rel(plano)} → issue #{numero} ({url}){'' if no_indice else ' — linha do índice não encontrada'}")
    return 0


def planos() -> list[Path]:
    return sorted(p for p in PASTA.glob("*.md") if p.name not in IGNORAR)


def verificar() -> int:
    faltando = []
    for p in planos():
        _, campos, _ = ler(p)
        if status_de(campos) in ATIVOS and not issue_de(campos):
            faltando.append(f"{status_de(campos):12} {rel(p)}")
    if faltando:
        print(f"{len(faltando)} plano(s) ativo(s) sem issue — rode `python tools/plano_issue.py criar <plano>`:")
        print("\n".join(f"  {x}" for x in faltando))
        return 1
    print("Todos os planos ATIVO/EM EXECUÇÃO têm issue.")
    return 0


def fechar(plano: Path, motivo: str | None) -> int:
    _, campos, _ = ler(plano)
    n = issue_de(campos)
    if not n:
        print(f"{rel(plano)} não tem issue; nada a fechar.")
        return 0
    texto = (f"kind: result\n\nPlano marcado como **{campos.get('status', '?')}**"
             f"{' (concluído ' + campos['concluido'] + ')' if campos.get('concluido') not in (None, '', 'null') else ''}."
             f"{chr(10) + chr(10) + motivo if motivo else ''}\n\nRegistro oficial: `{rel(plano)}`.")
    gh("issue", "comment", str(n), "--body", texto)
    gh("issue", "close", str(n))
    print(f"issue #{n} comentada e fechada.")
    return 0


def hook() -> int:
    """Lembrete para PostToolUse (Write/Edit). Nunca falha a sessão: sempre sai com 0."""
    try:
        dados = json.loads(sys.stdin.read() or "{}")
        caminho = (dados.get("tool_input") or {}).get("file_path") or ""
        if not caminho:
            return 0
        p = Path(caminho)
        if not p.is_absolute():
            p = RAIZ / p
        p = p.resolve()
        if p.parent != PASTA.resolve() or p.suffix != ".md" or p.name in IGNORAR or not p.exists():
            return 0
        _, campos, _ = ler(p)
        if status_de(campos) in ATIVOS and not issue_de(campos):
            aviso = (f"Plano {rel(p)} está {status_de(campos)} e ainda não tem issue. Regra do AGENTS.md "
                     f"(Planos e issues): rode `python tools/plano_issue.py criar {rel(p)}` antes de commitar.")
            print(json.dumps({"hookSpecificOutput": {"hookEventName": "PostToolUse",
                                                     "additionalContext": aviso}}, ensure_ascii=False))
    except Exception:
        pass
    return 0


def main(argv: list[str]) -> int:
    if not argv or argv[0] in {"-h", "--help"}:
        print(__doc__)
        return 0
    cmd, resto = argv[0], argv[1:]
    if cmd == "verificar":
        return verificar()
    if cmd == "hook":
        return hook()
    if cmd in {"criar", "fechar"} and resto:
        plano = Path(resto[0])
        plano = (plano if plano.is_absolute() else Path.cwd() / plano).resolve()
        if not plano.exists():
            raise SystemExit(f"plano não encontrado: {resto[0]}")
        if cmd == "criar":
            return criar(plano, "--dry-run" in resto)
        motivo = resto[resto.index("--motivo") + 1] if "--motivo" in resto else None
        return fechar(plano, motivo)
    print(__doc__)
    return 2


if __name__ == "__main__":
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    sys.exit(main(sys.argv[1:]))
