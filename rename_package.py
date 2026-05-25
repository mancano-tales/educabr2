"""Rename the R package from `educabr2` to `educabr2`.

Replaces all standalone occurrences of the lowercase word `educabr2` with
`educabr2`, except when it appears as part of one of these URL/path
contexts (which refer to the GitHub repo, the gh-pages site, or the
shinyapps app — none of which are being renamed):

  * mancano-tales/educabr2        (GitHub repo path)
  * shinyapps.io/educabr         (shinyapps app URL, partial)
  * github.io/educabr2            (pkgdown URL, partial)

Also leaves alone the literal `educabR` (Bissoli's CRAN package) since
the regex is case-sensitive.
"""
from __future__ import annotations
import re
from pathlib import Path

ROOT = Path(__file__).parent
EXCLUDED_DIRS = ("docs", ".Rproj.user", "check", ".git", ".claude", ".positai",
                 "Meta", "doc", "pkgdown")

# Match `educabr2` as a whole word, not already followed by `2` (idempotent).
PATTERN = re.compile(r"\beducabr\b(?!2)")

# When the match is part of one of these strings, leave it alone.
URL_CONTEXTS = (
    "mancano-tales/educabr2",
    "shinyapps.io/educabr",
    "github.io/educabr",
)

def in_excluded_dir(path: Path) -> bool:
    return any(part in EXCLUDED_DIRS for part in path.parts)

def in_url_context(text: str, start: int, end: int) -> bool:
    """Check if text[start:end] sits inside one of the URL_CONTEXTS strings."""
    window_start = max(0, start - 40)
    window_end = min(len(text), end + 5)
    chunk = text[window_start:window_end]
    for ctx in URL_CONTEXTS:
        idx = 0
        while True:
            idx = chunk.find(ctx, idx)
            if idx == -1:
                break
            # The 'educabr2' substring inside ctx
            ctx_offset = idx + ctx.find("educabr2")
            match_offset = start - window_start
            if ctx_offset == match_offset:
                return True
            idx += 1
    return False

def rename_file(path: Path) -> int:
    """Rename in-place; return number of replacements."""
    try:
        text = path.read_text(encoding="utf-8")
    except (UnicodeDecodeError, PermissionError):
        return 0
    matches = list(PATTERN.finditer(text))
    if not matches:
        return 0
    n = 0
    parts = []
    prev_end = 0
    for m in matches:
        if in_url_context(text, m.start(), m.end()):
            continue
        parts.append(text[prev_end:m.start()])
        parts.append("educabr2")
        prev_end = m.end()
        n += 1
    if n == 0:
        return 0
    parts.append(text[prev_end:])
    new_text = "".join(parts)
    path.write_text(new_text, encoding="utf-8")
    return n

def walk():
    """Yield files to consider."""
    extensions = {".R", ".Rmd", ".Rd", ".md", ".yml", ".yaml", ".json", ".py"}
    names = {"DESCRIPTION", "NAMESPACE", "WORDLIST"}
    for p in ROOT.rglob("*"):
        if not p.is_file() or in_excluded_dir(p):
            continue
        if p.suffix in extensions or p.name in names:
            yield p

def main():
    total = 0
    files_touched = 0
    for p in walk():
        n = rename_file(p)
        if n:
            files_touched += 1
            total += n
            print(f"{n:4d}  {p.relative_to(ROOT)}")
    print(f"\nReplaced {total} occurrences across {files_touched} files.")

if __name__ == "__main__":
    main()
