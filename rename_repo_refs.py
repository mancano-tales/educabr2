"""Update GitHub repo URL references after `educabr` -> `educabr2` rename.

Rewrites:
  * `mancano-tales/educabr2`  ->  `mancano-tales/educabr2`
  * `github.io/educabr2/`     ->  `github.io/educabr2/`     (pkgdown URL)
  * `github.io/educabr2#`     ->  `github.io/educabr2#`     (fragment links)

Leaves alone:
  * `shinyapps.io/educabr/`  (independent service slug)
  * `library(educabr2)`, `educabr2:::`, etc. (already renamed in commit 0bbdccd)
  * literal `educabR` (Bissoli's CRAN package — different case)
"""
from __future__ import annotations
import re
from pathlib import Path

ROOT = Path(__file__).parent
EXCLUDED_DIRS = ("docs", ".Rproj.user", "check", ".git", ".claude",
                 ".positai", "Meta", "doc", "pkgdown")

# Three rewrite rules. Each is (regex, replacement).
RULES = [
    # GitHub repo path: mancano-tales/educabr2  ->  mancano-tales/educabr2
    (re.compile(r"\bmancano-tales/educabr\b(?!2)"),
     "mancano-tales/educabr2"),

    # pkgdown URL (github.io/educabr2/ ...): github.io/educabr2/ ...
    (re.compile(r"\bgithub\.io/educabr(?=[/#)\s])(?!2)"),
     "github.io/educabr2"),
]

def in_excluded_dir(path: Path) -> bool:
    return any(part in EXCLUDED_DIRS for part in path.parts)

def rewrite_file(path: Path) -> int:
    try:
        text = path.read_text(encoding="utf-8")
    except (UnicodeDecodeError, PermissionError):
        return 0
    new_text = text
    n_total = 0
    for pattern, replacement in RULES:
        new_text, n = pattern.subn(replacement, new_text)
        n_total += n
    if n_total and new_text != text:
        path.write_text(new_text, encoding="utf-8")
    return n_total

def main():
    extensions = {".R", ".Rmd", ".Rd", ".md", ".yml", ".yaml", ".json", ".py"}
    names = {"DESCRIPTION", "NAMESPACE", "WORDLIST"}
    total = 0
    touched = 0
    for p in ROOT.rglob("*"):
        if not p.is_file() or in_excluded_dir(p):
            continue
        if p.suffix not in extensions and p.name not in names:
            continue
        n = rewrite_file(p)
        if n:
            touched += 1
            total += n
            print(f"{n:4d}  {p.relative_to(ROOT)}")
    print(f"\n{total} replacement(s) across {touched} file(s).")

if __name__ == "__main__":
    main()
