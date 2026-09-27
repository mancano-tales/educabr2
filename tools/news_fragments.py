"""Create permanent NEWS fragments and render their deterministic block into NEWS.md.

Fragments are the source records. The NEWS block is generated and should only be changed by this tool.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import uuid
from pathlib import Path

NEWS = "NEWS.md"
FRAGMENTS = Path("newsfragments")
BEGIN = "<!-- NEWS-FRAGMENTS:BEGIN -->"
END = "<!-- NEWS-FRAGMENTS:END -->"
MARKER = re.compile(r"<!-- NEWS-FRAGMENT:([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}) -->")
UUID_NAME = re.compile(r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")


class FragmentError(ValueError):
    pass


def git(root: Path, *args: str, check: bool = True) -> str:
    result = subprocess.run(["git", "-C", str(root), *args], capture_output=True, text=True,
                            encoding="utf-8", errors="replace")
    if check and result.returncode:
        raise FragmentError(f"git {' '.join(args[:3])}: {result.stderr.strip()}")
    return result.stdout.strip()


def find_source_commit(root: Path, relative_path: str) -> str | None:
    """Find the reachable commit that first added a fragment, including before merge commits."""
    log = git(root, "log", "HEAD", "--full-history", "-m", "--diff-filter=A", "--format=%H", "--", relative_path,
              check=False)
    for commit in reversed([line for line in log.splitlines() if line]):
        parents = git(root, "rev-list", "--parents", "-n", "1", commit).split()[1:]
        present_in_parent = any(
            subprocess.run(["git", "-C", str(root), "cat-file", "-e", f"{parent}:{relative_path}"],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0
            for parent in parents
        )
        if not present_in_parent:
            return commit
    return None


def parse_fragment(path: Path) -> tuple[str, str, str]:
    fragment_id = path.stem
    if not UUID_NAME.fullmatch(fragment_id):
        raise FragmentError(f"nome de fragmento não é UUID canônico: {path}")
    text = path.read_text(encoding="utf-8")
    match = re.fullmatch(r"---\r?\n(.*?)\r?\n---\r?\n(.*)", text, flags=re.S)
    if not match:
        raise FragmentError(f"frontmatter inválido em {path}; esperado title, agent e corpo Markdown")
    values: dict[str, str] = {}
    for line in match.group(1).splitlines():
        item = re.fullmatch(r"(title|agent): (.+)", line)
        if not item:
            raise FragmentError(f"metadado inválido em {path}: {line}")
        key, encoded = item.groups()
        if key in values:
            raise FragmentError(f"metadado duplicado em {path}: {key}")
        try:
            value = json.loads(encoded)
        except json.JSONDecodeError as exc:
            raise FragmentError(f"valor de {key} deve ser string JSON em {path}") from exc
        if not isinstance(value, str) or not value.strip():
            raise FragmentError(f"metadado vazio/inválido em {path}: {key}")
        if "\n" in value or "\r" in value or "<!-- NEWS-" in value:
            raise FragmentError(f"{key} deve ocupar uma linha sem marcadores reservados em {path}")
        values[key] = value.strip()
    if set(values) != {"title", "agent"}:
        raise FragmentError(f"{path} precisa de title e agent")
    body = match.group(2).strip()
    if not body or body == "Descreva aqui a mudança visível para quem usa o projeto.":
        raise FragmentError(f"preencha a descrição em {path}")
    if re.search(r"(?m)^#{1,2} ", body) or "<!-- NEWS-" in body:
        raise FragmentError(f"use subtítulos ### e não inclua marcadores reservados em {path}")
    if "**Metadados de Execução**:" in body:
        raise FragmentError(f"metadados de execução são gerados automaticamente em {path}")
    return values["title"], values["agent"], body


def commit_metadata(root: Path, commit: str) -> tuple[str, str, str, list[str]]:
    record = git(root, "show", "-s", "--format=%aI%x1f%an%x1f%s", commit).split("\x1f", 2)
    if len(record) != 3:
        raise FragmentError(f"não foi possível ler metadados do commit {commit}")
    date, author, subject = record
    parents = git(root, "rev-list", "--parents", "-n", "1", commit).split()[1:]
    files = (git(root, "diff", "--name-only", parents[0], commit) if parents else
             git(root, "diff-tree", "--root", "--no-commit-id", "--name-only", "-r", commit)).splitlines()
    return date[:10], author, subject, files


def render_entries(root: Path) -> list[str]:
    directory = root / FRAGMENTS
    known = set(git(root, "log", "HEAD", "--full-history", "-m", "--diff-filter=A", "--format=",
                    "--name-only", "--", "newsfragments/*.md").splitlines())
    missing = sorted(name for name in known if name and not (root / name).is_file())
    if missing:
        raise FragmentError("fragmentos permanentes ausentes: " + ", ".join(missing))
    if not directory.exists():
        return []
    rendered: list[tuple[str, str, str]] = []
    for path in sorted(directory.glob("*.md")):
        fragment_id = path.stem
        title, agent, body = parse_fragment(path)
        relative = path.relative_to(root).as_posix()
        commit = find_source_commit(root, relative)
        if not commit:
            raise FragmentError(f"{relative} ainda não está em um commit acessível; co-commite o fragmento com a mudança")
        blob = subprocess.run(["git", "-C", str(root), "show", f"{commit}:{relative}"], check=True,
                              capture_output=True, text=True, encoding="utf-8", errors="replace").stdout
        if path.read_text(encoding="utf-8").replace("\r\n", "\n") != blob.replace("\r\n", "\n"):
            raise FragmentError(f"fragmento é permanente: não edite {relative}; crie outro para registrar uma nova mudança")
        date, author, subject, files = commit_metadata(root, commit)
        affected = [name for name in files if name != relative]
        listed_files = ", ".join(f"`{name}`" for name in affected) or "(nenhum)"
        declared_agent = agent or author
        metadata = (
            "**Metadados de Execução**:\n"
            f"- **Data**: {date}\n"
            f"- **Agente**: {declared_agent}\n"
            f"- **Mensagem do Commit**: {json.dumps(subject, ensure_ascii=False)}\n"
            f"- **Arquivos afetados**: {listed_files}"
        )
        heading = f"## {date} — {title} <!-- NEWS-FRAGMENT:{fragment_id} -->"
        rendered.append((date, fragment_id, f"{heading}\n\n{body}\n\n{metadata}"))
    # Dates descend; UUID breaks same-day ties deterministically across clones.
    rendered.sort(key=lambda item: (item[0], item[1]), reverse=True)
    return [entry for _, _, entry in rendered]


def generated_block(root: Path) -> str:
    entries = render_entries(root)
    return BEGIN + "\n" + "\n\n".join(entries) + "\n" + END


def replace_generated_region(text: str, block: str) -> str:
    eol = "\r\n" if "\r\n" in text else "\n"
    block = block.replace("\n", eol)
    begin_matches = list(re.finditer(r"(?m)^" + re.escape(BEGIN) + r"(?=\r?$)", text))
    end_matches = list(re.finditer(r"(?m)^" + re.escape(END) + r"(?=\r?$)", text))
    if begin_matches or end_matches:
        if len(begin_matches) != 1 or len(end_matches) != 1 or begin_matches[0].start() >= end_matches[0].start():
            raise FragmentError("marcadores de NEWS gerado ausentes, duplicados ou fora de ordem")
        tail = text[end_matches[0].end():]
        if tail.startswith(eol) and not tail.startswith(eol + eol):
            tail = eol + tail
        elif not tail.startswith(eol):
            tail = eol + eol + tail
        return text[:begin_matches[0].start()] + block + tail
    heading = re.search(r"(?m)^# .*(?:\r?\n|$)", text)
    if not heading:
        raise FragmentError("NEWS.md precisa de um título # para inicializar a região gerada")
    return text[:heading.end()] + eol + block + eol + text[heading.end():]


def create_fragment(root: Path, title: str, agent: str | None, body: str | None) -> Path:
    title = title.strip()
    if not title or "\n" in title or "\r" in title:
        raise FragmentError("informe --title em uma única linha")
    agent = (agent or os.environ.get("NEWS_AGENT") or git(root, "config", "user.name", check=False) or "agente não informado").strip()
    if not agent:
        raise FragmentError("informe --agent ou configure NEWS_AGENT")
    fragment_id = str(uuid.uuid4())
    relative_path = f"{FRAGMENTS.as_posix()}/{fragment_id}.md"
    ignored = subprocess.run(["git", "-C", str(root), "check-ignore", "-q", "--", relative_path],
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0
    if ignored:
        raise FragmentError("newsfragments/ está no .gitignore; libere o diretório antes de criar o registro")
    directory = root / FRAGMENTS
    directory.mkdir(parents=True, exist_ok=True)
    path = directory / f"{fragment_id}.md"
    content = (
        "---\n"
        f"title: {json.dumps(title, ensure_ascii=False)}\n"
        f"agent: {json.dumps(agent, ensure_ascii=False)}\n"
        "---\n"
        + ((body or "Descreva aqui a mudança visível para quem usa o projeto.").strip() + "\n")
    )
    path.write_text(content, encoding="utf-8", newline="")
    return path


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    create = sub.add_parser("create", help="cria um fragmento Markdown com UUID")
    create.add_argument("--title", required=True)
    create.add_argument("--agent")
    create.add_argument("--body")
    render = sub.add_parser("render", help="atualiza a região gerada em NEWS.md")
    render.add_argument("--check", action="store_true", help="falha se NEWS.md estiver desatualizado, sem escrever")
    args = parser.parse_args(argv)
    root = Path.cwd()
    try:
        if args.command == "create":
            path = create_fragment(root, args.title, args.agent, args.body)
            print(path.relative_to(root).as_posix())
            return 0
        news_path = root / NEWS
        if not news_path.is_file():
            raise FragmentError(f"rode da raiz de um repositório com {NEWS}")
        original = news_path.read_bytes().decode("utf-8")
        expected = replace_generated_region(original, generated_block(root))
        if args.check:
            if original != expected:
                print("NEWS.md está desatualizado; rode python tools/news_fragments.py render")
                return 1
            print("NEWS.md está atualizado")
            return 0
        if original != expected:
            news_path.write_bytes(expected.encode("utf-8"))
        print(f"NEWS.md atualizado ({len(render_entries(root))} fragmentos)")
        return 0
    except (FragmentError, OSError) as exc:
        print(f"erro: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
