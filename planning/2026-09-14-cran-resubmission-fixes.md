# CRAN Resubmission Fixes (0.1.0 → 0.1.1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Clear every item in the CRAN pre-test rejection of `educabr2_0.1.0` (LaTeX `≥` error in the PDF manual, invalid `LICENSE.md` URI in README, misspelled-words NOTE), remove Artur Damião from the author list, bump to 0.1.1 and rewrite `cran-comments.md` as a resubmission — **without touching the uncommitted work of another agent** that is present in the working tree.

**Architecture:** Documentation-only change. The root cause of the ERROR+WARNING is a single character (`≥`, U+2265) in two roxygen comments that R's Rd→LaTeX converter does not map; replacing it with ASCII `>=` and adding a regression test that scans the Rd database fixes it permanently. The `LICENSE.md` NOTE is a relative README link to a file excluded by `.Rbuildignore`; it becomes an absolute URL. The spelling NOTE is proper nouns and is answered in `cran-comments.md`. Author removal is done in `DESCRIPTION` + `README.md` and propagated to `man/educabr2-package.Rd` via `devtools::document()`.

**Tech Stack:** R 4.6.0, roxygen2 8.0.0, testthat 3, TinyTeX/pdflatex (local), pandoc 3.9 (local), git.


> **Status (2026-09-14): EXECUTADO.** Commits `3ddc94e`..`8a9ce60` em `main`. `R CMD check --as-cran` no tarball com manual PDF: 0 errors / 0 warnings / 1 NOTE (New submission). Task 6 ficou obsoleta (o outro agente commitou seus hunks em `0ab1a08`). Task 9 (push + webform) é do autor.

---

## ⚠️ Multi-agent safety (read before any step)

At planning time (2026-09-14) the working tree has **four uncommitted files belonging to another agent** — a "Related work / educabR" section added in:

- `R/educabr2-package.R` (new `@section Related work:`)
- `man/educabr2-package.Rd` (its roxygen output)
- `README.md` (new paragraph after line 310, "In practice: need current-year microdata…")
- `vignettes/introduction.Rmd` (new `### Scope and related packages`)

**Rules for this plan:**

1. **Never** run `git add .`, `git add -A`, `git stash`, `git checkout -- <file>`, or `git commit -a`.
2. Two of those files must also be edited by this plan (`README.md`, `man/educabr2-package.Rd`). For them, stage **only our hunks** using the `git update-index --cacheinfo` technique in Task 6 (it builds the staged blob from `HEAD` + our edit, leaving the working tree — and the other agent's hunks — untouched).
3. Files this plan owns exclusively and may `git add` normally: `R/data.R`, `R/get_attainment.R`, `man/get_attainment.Rd`, `man/lee_lee_2016.Rd`, `DESCRIPTION`, `NEWS.md`, `cran-comments.md`, `tests/testthat/test-rd-latex-safe.R`, `planning/2026-09-14-cran-resubmission-fixes.md`.
4. Before Task 6, re-run `git status --short`. If the other agent has meanwhile committed its work (the four files no longer show `M`), Task 6's `update-index` dance is unnecessary — plain `git add README.md man/educabr2-package.Rd` is fine. If *new* foreign changes appeared in files this plan owns, stop and ask the user.
5. **Alternative chosen by the user:** if the user says the foreign hunks are finished and may be committed, commit them first as their own commit (`docs: describe relationship with educabR`) and then run this plan with plain `git add`.

---

## File Structure

| File | Responsibility | Action |
|---|---|---|
| `R/data.R:310` | roxygen for `lee_lee_2016` dataset — contains `≥` | Modify (`≥` → `>=`) |
| `R/get_attainment.R:15` | roxygen for `get_attainment()` — contains `≥` | Modify (`≥` → `>=`) |
| `man/lee_lee_2016.Rd`, `man/get_attainment.Rd` | roxygen output | Regenerate via `devtools::document()` |
| `tests/testthat/test-rd-latex-safe.R` | regression test: no LaTeX-unsafe math glyphs in any Rd | Create |
| `DESCRIPTION` | remove Artur Damião; `Version: 0.1.1` | Modify |
| `man/educabr2-package.Rd` | author list (roxygen output of `DESCRIPTION`) | Regenerate (shared with other agent — partial stage) |
| `README.md:7`, `:363`, `:383-394` | `LICENSE.md` relative links; suggested citation (author + version) | Modify (shared with other agent — partial stage) |
| `NEWS.md:1` | version header + resubmission note | Modify |
| `cran-comments.md` | rewrite as "Resubmission" answering each pre-test item | Rewrite |

Not touched: `inst/dashboard/manifest.json` (gitignored, regenerated on deploy), `docs/` (pkgdown output, gitignored, rebuilt by CI), `inst/WORDLIST` (already lists the flagged proper nouns).

---

### Task 1: Reproduce the LaTeX failure locally

**Files:** none modified.

- [x] **Step 1: Build the PDF manual the way CRAN does**

Run (Git Bash, from package root):

```bash
SCRATCH="C:/Users/Mancano/AppData/Local/Temp/claude/C--Users-Mancano-Documents-MancanoSync-educabr2/8c3a961c-4173-4d9c-aec8-969c81910dab/scratchpad"
mkdir -p "$SCRATCH/manual" && R CMD Rd2pdf --no-preview --force -o "$SCRATCH/manual/educabr2-manual.pdf" . 2>&1 | tail -25
```

Expected: FAIL. Output contains `! LaTeX Error: Unicode character ≥ (U+2265) not set up for use with LaTeX.` (four times — two Rd files × two occurrences). This confirms the local toolchain reproduces CRAN's WARNING/ERROR; `devtools::check()` had hidden it because it defaults to `--no-manual`.

- [x] **Step 2: Confirm the offending sources**

Run:

```bash
grep -rn "≥" R man vignettes README.md DESCRIPTION NEWS.md
```

Expected (exactly four lines):

```
R/data.R:310:#' By construction, primary ≥ secondary ≥ tertiary for any
R/get_attainment.R:15:#' - `level = "primary"` ≥ `level = "secondary"` ≥ `level = "tertiary"`.
man/get_attainment.Rd:72:\item \code{level = "primary"} ≥ \code{level = "secondary"} ≥ \code{level = "tertiary"}.
man/lee_lee_2016.Rd:64:By construction, primary ≥ secondary ≥ tertiary for any
```

---

### Task 2: Regression test for LaTeX-unsafe glyphs in Rd files

**Files:**
- Create: `tests/testthat/test-rd-latex-safe.R`

- [x] **Step 1: Write the failing test**

```r
# Guards against the CRAN pre-test failure of 0.1.0: a Unicode math glyph
# (U+2265 "≥") in roxygen text broke the PDF manual because R's Rd->LaTeX
# converter has no mapping for it. Dashes, accents and quotes are fine.

test_that("Rd files contain no math glyphs that LaTeX cannot typeset", {
  pkg_root <- system.file(package = "educabr2")
  db <- if (dir.exists(file.path(pkg_root, "man"))) {
    tools::Rd_db(dir = pkg_root)          # devtools::load_all() / source tree
  } else {
    tools::Rd_db(package = "educabr2")    # installed package (R CMD check)
  }
  expect_gt(length(db), 0)

  unsafe <- "[\u2265\u2264\u2260\u00d7\u00b1\u2192\u2190\u221e\u2248]"
  txt <- vapply(db, function(rd) paste(as.character(rd), collapse = ""),
                character(1))
  offenders <- names(db)[grepl(unsafe, txt, perl = TRUE)]

  expect_length(offenders, 0)
  if (length(offenders)) {
    message("Rd files with LaTeX-unsafe glyphs: ",
            paste(offenders, collapse = ", "))
  }
})
```

- [x] **Step 2: Run it to verify it fails**

Run:

```bash
Rscript -e 'devtools::load_all(quiet = TRUE); testthat::test_file("tests/testthat/test-rd-latex-safe.R")'
```

Expected: `[ FAIL 1 | WARN 0 | SKIP 0 | PASS 1 ]` with message `Rd files with LaTeX-unsafe glyphs: get_attainment.Rd, lee_lee_2016.Rd`.

---

### Task 3: Replace `≥` with `>=` in the roxygen sources

**Files:**
- Modify: `R/data.R:310`
- Modify: `R/get_attainment.R:15`
- Regenerate: `man/lee_lee_2016.Rd`, `man/get_attainment.Rd`

- [x] **Step 1: Edit the two roxygen lines**

`R/data.R` line 310 — change:

```r
#' By construction, primary ≥ secondary ≥ tertiary for any
```

to:

```r
#' By construction, primary >= secondary >= tertiary for any
```

`R/get_attainment.R` line 15 — change:

```r
#' - `level = "primary"` ≥ `level = "secondary"` ≥ `level = "tertiary"`.
```

to:

```r
#' - `level = "primary"` >= `level = "secondary"` >= `level = "tertiary"`.
```

Command form (both edits, Git Bash):

```bash
sed -i 's/primary ≥ secondary ≥ tertiary/primary >= secondary >= tertiary/' R/data.R
sed -i 's/`level = "primary"` ≥ `level = "secondary"` ≥ `level = "tertiary"`/`level = "primary"` >= `level = "secondary"` >= `level = "tertiary"`/' R/get_attainment.R
grep -rn "≥" R/ ; echo "exit=$? (1 means no matches — good)"
```

- [x] **Step 2: Regenerate the Rd files**

Run:

```bash
Rscript -e 'devtools::document()'
git status --short man/
```

Expected: `man/get_attainment.Rd` and `man/lee_lee_2016.Rd` now show `M`; `man/educabr2-package.Rd` still shows `M` (the other agent's hunk — unchanged by us at this point). No other `man/` file changes. If any other Rd changes appear, inspect with `git diff man/<file>` before continuing.

- [x] **Step 3: Run the regression test — expect pass**

Run:

```bash
Rscript -e 'devtools::load_all(quiet = TRUE); testthat::test_file("tests/testthat/test-rd-latex-safe.R")'
```

Expected: `[ FAIL 0 | WARN 0 | SKIP 0 | PASS 2 ]`.

- [x] **Step 4: Rebuild the PDF manual — expect success**

Run:

```bash
SCRATCH="C:/Users/Mancano/AppData/Local/Temp/claude/C--Users-Mancano-Documents-MancanoSync-educabr2/8c3a961c-4173-4d9c-aec8-969c81910dab/scratchpad"
R CMD Rd2pdf --no-preview --force -o "$SCRATCH/manual/educabr2-manual.pdf" . 2>&1 | tail -5 && ls -la "$SCRATCH/manual/educabr2-manual.pdf"
```

Expected: last lines contain `Saving output to ...educabr2-manual.pdf ... done`; the PDF exists and is > 100 KB. No `LaTeX Error` lines.

- [x] **Step 5: Commit (only our files)**

```bash
git add R/data.R R/get_attainment.R man/get_attainment.Rd man/lee_lee_2016.Rd tests/testthat/test-rd-latex-safe.R
git commit -m "fix(docs): replace U+2265 with ASCII >= in Rd text so the PDF manual builds

CRAN pre-test for 0.1.0 failed with 'Unicode character ≥ (U+2265) not set
up for use with LaTeX' in get_attainment.Rd and lee_lee_2016.Rd. Adds a
testthat guard that scans the Rd database for LaTeX-unsafe math glyphs.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 4: Remove Artur Damião from the author list

**Files:**
- Modify: `DESCRIPTION:9-16`
- Regenerate: `man/educabr2-package.Rd` (shared with other agent — do **not** stage yet)

- [x] **Step 1: Edit `Authors@R` in `DESCRIPTION`**

Change lines 4–16 from:

```
Authors@R: c(
    person("Tales", "Mançano",
           email = "mancano.tales@usp.br",
           role = c("aut", "cre"),
           comment = c(ORCID = "0000-0001-5923-9743")),
    person("Victor", "Alcantara",
           email = "victorgalcantara@usp.br",
           role = "ctb",
           comment = c(ORCID = "0000-0001-8846-9652")),
    person("Artur", "Damião",
           email = "artur.cardoso@usp.br",
           role = "ctb",
           comment = c(ORCID = "0000-0002-8628-1653")))
```

to:

```
Authors@R: c(
    person("Tales", "Mançano",
           email = "mancano.tales@usp.br",
           role = c("aut", "cre"),
           comment = c(ORCID = "0000-0001-5923-9743")),
    person("Victor", "Alcantara",
           email = "victorgalcantara@usp.br",
           role = "ctb",
           comment = c(ORCID = "0000-0001-8846-9652")))
```

Note the closing `))` after Victor's `comment = ...` becomes `)))` (closes `person(`, then `c(`).

- [x] **Step 2: Verify DESCRIPTION still parses and lists two people**

Run:

```bash
Rscript -e 'a <- eval(parse(text = read.dcf("DESCRIPTION", fields = "Authors@R")[[1]])); print(a); stopifnot(length(a) == 2L)'
```

Expected: prints Tales Mançano `[aut, cre]` and Victor Alcantara `[ctb]`; no error.

- [x] **Step 3: Regenerate `man/educabr2-package.Rd`**

Run:

```bash
Rscript -e 'devtools::document()'
git diff man/educabr2-package.Rd | grep '^[-+]' | grep -v '^[-+][-+]'
```

Expected: the diff versus `HEAD` now shows (a) the other agent's `+\section{Related work}{…}` block **and** (b) our single removed line:

```
-  \item Artur Damião \email{artur.cardoso@usp.br} (\href{https://orcid.org/0000-0002-8628-1653}{ORCID}) [contributor]
```

Nothing else. Do **not** `git add` this file yet — see Task 6.

- [x] **Step 4: Confirm `citation()` no longer lists Damião**

Run:

```bash
Rscript -e 'devtools::load_all(quiet = TRUE); print(citation("educabr2"), style = "text")'
```

Expected: `Mançano T, Alcantara V (2026). educabr2: Harmonized Historical Series on Brazilian Education. R package version 0.1.0 …` — no Damião. (Version still 0.1.0 here; bumped in Task 5.)

---

### Task 5: Version bump, NEWS, README citation and LICENSE links

**Files:**
- Modify: `DESCRIPTION:3`
- Modify: `NEWS.md:1-2`
- Modify: `README.md:7`, `README.md:363`, `README.md:383-394` (shared with other agent — do **not** stage yet)

- [x] **Step 1: Bump `Version:` to 0.1.1**

CRAN policy: "Increasing the version number at each submission reduces confusion so is preferred even when a previous submission was not accepted." In `DESCRIPTION` line 3 change `Version: 0.1.0` → `Version: 0.1.1`.

```bash
sed -i 's/^Version: 0\.1\.0$/Version: 0.1.1/' DESCRIPTION && grep -n '^Version' DESCRIPTION
```

Expected: `3:Version: 0.1.1`.

- [x] **Step 2: Update `NEWS.md` header and add a resubmission block**

Replace lines 1–2 (`# educabr2 0.1.0` + blank line) with:

```markdown
# educabr2 0.1.1

## CRAN resubmission (2026-09-14)

* Fixed the PDF manual build: the Unicode glyph `≥` (U+2265) in the
  `get_attainment()` and `lee_lee_2016` documentation is now ASCII
  `>=`; a testthat guard scans every Rd file for LaTeX-unsafe math
  glyphs.
* `README.md` no longer links to the build-ignored `LICENSE.md` by
  relative path (flagged as an invalid file URI by CRAN).
* Author list: Artur Damião removed from `Authors@R` and from the
  suggested citation.
* Version 0.1.0 was rejected by CRAN's incoming pre-tests and was
  never published; 0.1.1 is the same release with the fixes above.

```

The existing `First CRAN release. Six themes …` paragraph and everything below it remain unchanged (they now sit under the 0.1.1 header). Leave the second `# educabr2 0.1.0` header at ~line 137 alone — it is pre-existing history and not in scope.

Command form:

```bash
python - <<'EOF'
import io
p = "NEWS.md"
s = io.open(p, encoding="utf-8").read()
assert s.startswith("# educabr2 0.1.0\n\n")
block = """# educabr2 0.1.1

## CRAN resubmission (2026-09-14)

* Fixed the PDF manual build: the Unicode glyph `≥` (U+2265) in the
  `get_attainment()` and `lee_lee_2016` documentation is now ASCII
  `>=`; a testthat guard scans every Rd file for LaTeX-unsafe math
  glyphs.
* `README.md` no longer links to the build-ignored `LICENSE.md` by
  relative path (flagged as an invalid file URI by CRAN).
* Author list: Artur Damião removed from `Authors@R` and from the
  suggested citation.
* Version 0.1.0 was rejected by CRAN's incoming pre-tests and was
  never published; 0.1.1 is the same release with the fixes above.

"""
io.open(p, "w", encoding="utf-8", newline="\n").write(block + s[len("# educabr2 0.1.0\n\n"):])
EOF
head -20 NEWS.md
```

(Use `python` if available; otherwise make the same edit with the Edit tool. `NEWS.md` is not in the CRAN tarball's LaTeX path, so `≥` inside it is harmless.)

- [x] **Step 3: Fix the two `LICENSE.md` links in `README.md`**

`LICENSE.md` is in `.Rbuildignore` (correct — CRAN does not want the GPL text shipped), so any relative link to it inside the tarball's README is dead. Change both to absolute URLs.

Line 7, change:

```markdown
[![License: GPL (>= 3)](https://img.shields.io/badge/License-GPL--3-blue.svg)](LICENSE.md)
```

to:

```markdown
[![License: GPL (>= 3)](https://img.shields.io/badge/License-GPL--3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)
```

Line 363, change:

```markdown
See [`LICENSE.md`](LICENSE.md).
```

to:

```markdown
See [`LICENSE.md`](https://github.com/mancano-tales/educabr2/blob/main/LICENSE.md).
```

Command form:

```bash
sed -i 's|blue\.svg)\](LICENSE\.md)|blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)|' README.md
sed -i 's|See \[`LICENSE\.md`\](LICENSE\.md)\.|See [`LICENSE.md`](https://github.com/mancano-tales/educabr2/blob/main/LICENSE.md).|' README.md
grep -n "LICENSE.md" README.md
```

Expected: two lines, both with `https://` targets; no bare `(LICENSE.md)` left.

- [x] **Step 4: Update the suggested citation in `README.md`**

Lines ~383–394. Change:

```markdown
Mançano, T., Alcantara, V., & Damião, A. (2026). *educabr2: Harmonized
Historical Series on Brazilian Education* (R package version
0.1.0.9000). GitHub. <https://github.com/mancano-tales/educabr2>
```

to:

```markdown
Mançano, T., & Alcantara, V. (2026). *educabr2: Harmonized
Historical Series on Brazilian Education* (R package version
0.1.1). GitHub. <https://github.com/mancano-tales/educabr2>
```

and in the BibTeX block change:

```bibtex
  author = {Tales Mançano and Victor Alcantara and Artur Damião},
  year   = {2026},
  note   = {R package version 0.1.0.9000},
```

to:

```bibtex
  author = {Tales Mançano and Victor Alcantara},
  year   = {2026},
  note   = {R package version 0.1.1},
```

Command form:

```bash
sed -i 's/Mançano, T., Alcantara, V., & Damião, A\. (2026)\./Mançano, T., \& Alcantara, V. (2026)./' README.md
sed -i 's/author = {Tales Mançano and Victor Alcantara and Artur Damião},/author = {Tales Mançano and Victor Alcantara},/' README.md
sed -i 's/0\.1\.0\.9000/0.1.1/g' README.md
grep -n "Damião\|0\.1\.0\|0\.1\.1" README.md
```

Expected: no `Damião`; no `0.1.0`; two lines with `0.1.1`.

- [x] **Step 5: Spell-check (WORDLIST already covers the proper nouns)**

Run:

```bash
Rscript -e 'print(spelling::spell_check_package("."))'
```

Expected: `No spelling errors found.` (or only words already present before this plan — compare against `git stash`-free baseline by eye; do not add words unless introduced by this plan).

- [x] **Step 6: Commit the exclusively-owned files now**

```bash
git add DESCRIPTION NEWS.md
git commit -m "chore(release): bump to 0.1.1 and drop Artur Damião from Authors@R

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

`README.md` and `man/educabr2-package.Rd` are committed in Task 6.

---

### Task 6: Stage only our hunks in the two files shared with the other agent

**Files:**
- Stage (partial): `README.md`, `man/educabr2-package.Rd`

Rationale: both files also carry the other agent's uncommitted "Related work" hunks. `git add <file>` would sweep those in. We build the staged blob as *HEAD + our edit only*, write it to the index with `git update-index --cacheinfo`, and leave the working tree untouched.

- [x] **Step 0: Re-check the working tree**

```bash
git status --short
```

If `README.md`, `man/educabr2-package.Rd`, `R/educabr2-package.R`, `vignettes/introduction.Rmd` no longer show `M` with the foreign hunks (i.e. the other agent committed), skip to Step 4 and use plain `git add README.md man/educabr2-package.Rd`.

- [x] **Step 1: Build the staged `README.md` = HEAD + our four edits**

```bash
SCRATCH="C:/Users/Mancano/AppData/Local/Temp/claude/C--Users-Mancano-Documents-MancanoSync-educabr2/8c3a961c-4173-4d9c-aec8-969c81910dab/scratchpad"
mkdir -p "$SCRATCH/stage"
git show HEAD:README.md > "$SCRATCH/stage/README.md"
sed -i 's|blue\.svg)\](LICENSE\.md)|blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)|' "$SCRATCH/stage/README.md"
sed -i 's|See \[`LICENSE\.md`\](LICENSE\.md)\.|See [`LICENSE.md`](https://github.com/mancano-tales/educabr2/blob/main/LICENSE.md).|' "$SCRATCH/stage/README.md"
sed -i 's/Mançano, T., Alcantara, V., & Damião, A\. (2026)\./Mançano, T., \& Alcantara, V. (2026)./' "$SCRATCH/stage/README.md"
sed -i 's/author = {Tales Mançano and Victor Alcantara and Artur Damião},/author = {Tales Mançano and Victor Alcantara},/' "$SCRATCH/stage/README.md"
sed -i 's/0\.1\.0\.9000/0.1.1/g' "$SCRATCH/stage/README.md"
# sanity: staged candidate must differ from HEAD only in our lines
diff <(git show HEAD:README.md) "$SCRATCH/stage/README.md"
```

Expected `diff` output: exactly 5 changed lines (badge link, "See LICENSE", APA author line, APA version line, BibTeX author line, BibTeX note line — 6 `<`/`>` pairs at most), and **no** lines mentioning "In practice: need **current-year microdata**" (that is the foreign hunk and must be absent).

- [x] **Step 2: Build the staged `man/educabr2-package.Rd` = HEAD − Artur line**

```bash
git show HEAD:man/educabr2-package.Rd | grep -v 'Artur Damião' > "$SCRATCH/stage/educabr2-package.Rd"
diff <(git show HEAD:man/educabr2-package.Rd) "$SCRATCH/stage/educabr2-package.Rd"
```

Expected: exactly one `<` line (the `\item Artur Damião …` line). No `Related work` lines.

Cross-check that it matches what roxygen produced (working tree minus the foreign section):

```bash
diff <(grep -v -F -e 'Related work' -e 'static long-run panel' -e 'connection to INEP' -e 'Escolar, SAEB' -e 'see \href{https://github.com/SidneyBissoli/educabR}' -e 'instead. The two packages' -e 'different axes' -e 'source there)' man/educabr2-package.Rd | sed '/^\\section{Related work}{$/,/^}$/d') "$SCRATCH/stage/educabr2-package.Rd" || true
```

Expected: empty or whitespace-only differences (this is a sanity aid, not a gate — Step 5's `R CMD check` is the gate).

- [x] **Step 3: Write both blobs to the index without touching the working tree**

```bash
b1=$(git hash-object -w "$SCRATCH/stage/README.md")
git update-index --cacheinfo 100644,$b1,README.md
b2=$(git hash-object -w "$SCRATCH/stage/educabr2-package.Rd")
git update-index --cacheinfo 100644,$b2,man/educabr2-package.Rd
git status --short
git diff --cached --stat
```

Expected: `README.md` and `man/educabr2-package.Rd` show `MM` (staged + unstaged); `git diff --cached --stat` lists exactly those two files; `git diff` (unstaged) for those two files now shows **only** the other agent's "Related work" hunks.

- [x] **Step 4: Commit**

```bash
git commit -m "docs: absolute LICENSE links in README and updated suggested citation

CRAN flagged the relative link to the build-ignored LICENSE.md as an
invalid file URI. Citation now lists the two current authors and
version 0.1.1.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
git status --short
```

Expected after commit: the four foreign files still show ` M` (unstaged) with only the other agent's hunks; nothing of ours is left unstaged. Verify:

```bash
git diff | grep '^[-+]' | grep -v '^[-+][-+]' | grep -c "Damião\|LICENSE\|0\.1\.1" ; echo "(expect 0)"
```

---

### Task 7: Rewrite `cran-comments.md` as a resubmission

**Files:**
- Modify: `cran-comments.md` (full rewrite)

- [x] **Step 1: Write the new content**

Replace the entire file with:

```markdown
## Resubmission

This is a resubmission of `educabr2` (now version 0.1.1; the 0.1.0
submission of 2026-09-13 did not pass the incoming pre-tests and was
never published). Changes since 0.1.0:

* **PDF manual (WARNING + ERROR on both flavours):** the Unicode
  character `≥` (U+2265) appeared in two Rd files
  (`get_attainment.Rd`, `lee_lee_2016.Rd`) and has no LaTeX mapping.
  Replaced with ASCII `>=`; a unit test now scans the Rd database for
  LaTeX-unsafe math glyphs. `R CMD check --as-cran` with the manual
  enabled now passes locally (pdflatex via TinyTeX).
* **Invalid file URI `LICENSE.md` from `README.md` (NOTE):** the
  relative link pointed to a file excluded by `.Rbuildignore`. Both
  links now use absolute URLs (gnu.org licence page; GitHub blob).
* **Possibly misspelled words in DESCRIPTION (NOTE):** these are
  proper nouns — names of Brazilian statistical sources and authors
  (Censo Escolar, PNAD, Censo Demográfico, Anuário Estatístico,
  IBGE, INEP, CENSUP, FGV-IBRE, Kang). The fragments `fico`, `rio`,
  `stico` reported on the Windows flavour are the UTF-8 tails of
  Demográfico / Anuário / Estatístico split by the tokenizer, not
  separate words.
* **Non-standard file `educabr2-manual.tex` (NOTE, Debian):** a
  by-product of the failed LaTeX run above; resolved with it.
* Author list updated: one contributor (`ctb`) removed at their
  request.

## Test environments

* Local Windows 11, R 4.6.0 (release), `R CMD check --as-cran` on the
  built tarball with the PDF manual — 0 errors, 0 warnings, 1 note
  (new submission).
* GitHub Actions:
  - ubuntu-latest (devel, release, oldrel-1)
  - macos-latest (release)
  - windows-latest (devel, release)

## R CMD check results

0 errors | 0 warnings | 1 note

* "New submission" — expected for a first release.

## Reverse dependencies

None (first release).

## Notes for the reviewer

* Source size is ~0.3 MB; the six packaged datasets total ~80 KB on
  disk (compressed `.rda`).
* No external network access at runtime; no system-level dependencies.
* `Suggests:` lists Shiny, plotly, DT, bslib, and scales for the
  bundled dashboard (`run_dashboard()`); none are loaded unless the
  user invokes the dashboard.
* Vignettes are knitted in English and Portuguese.
```

(If the user prefers not to state "at their request" for the author change, use "Author list updated: one contributor removed.")

- [x] **Step 2: Commit**

```bash
git add cran-comments.md
git commit -m "docs(cran): rewrite cran-comments.md as the 0.1.1 resubmission

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 8: Full verification — build tarball and `R CMD check --as-cran` with the manual

**Files:** none modified (outputs go to the scratchpad).

- [x] **Step 1: Build the source tarball**

```bash
SCRATCH="C:/Users/Mancano/AppData/Local/Temp/claude/C--Users-Mancano-Documents-MancanoSync-educabr2/8c3a961c-4173-4d9c-aec8-969c81910dab/scratchpad"
mkdir -p "$SCRATCH/check" && cd "$SCRATCH/check" && R CMD build "C:/Users/Mancano/Documents/MancanoSync/educabr2" 2>&1 | tail -5 && ls -la educabr2_0.1.1.tar.gz
```

Expected: `* building 'educabr2_0.1.1.tar.gz'`; file ~0.3 MB. (pandoc 3.9 is available locally, so vignettes build.)

Note: the tarball is built from the **working tree**, so it includes the other agent's uncommitted "Related work" prose. That is fine for verification — it is plain text with no LaTeX-unsafe glyphs — but the tarball actually uploaded to CRAN must be built from a clean, fully committed tree (Task 9).

- [x] **Step 2: Run the check exactly as CRAN's pre-test does**

```bash
cd "$SCRATCH/check" && _R_CHECK_CRAN_INCOMING_REMOTE_=false R CMD check --as-cran educabr2_0.1.1.tar.gz 2>&1 | tee check.log | grep -E "^\* checking|Status:|WARNING|ERROR|NOTE" | grep -vE "\.\.\. OK$"
```

Expected (the only non-OK lines):

```
* checking CRAN incoming feasibility ... NOTE
Status: 1 NOTE
```

And explicitly these lines must be `OK`:

```bash
grep -E "checking PDF version of manual|checking for non-standard things|checking Rd files" "$SCRATCH/check/check.log"
```

Expected:

```
* checking Rd files ... OK
* checking PDF version of manual ... OK
* checking for non-standard things in the check directory ... OK
```

Read the NOTE body:

```bash
sed -n '/CRAN incoming feasibility/,/^\* checking/p' "$SCRATCH/check/00check.log" 2>/dev/null || sed -n '/CRAN incoming feasibility/,/^\* checking/p' "$SCRATCH/check/educabr2.Rcheck/00check.log"
```

Expected: `New submission` plus (possibly) the proper-noun spelling list; **no** `invalid file URI` line; **no** `Damião` in the Maintainer/Author lines.

- [x] **Step 3: Run the full test suite once more**

```bash
cd "C:/Users/Mancano/Documents/MancanoSync/educabr2" && Rscript -e 'devtools::test()' 2>&1 | tail -6
```

Expected: `[ FAIL 0 | WARN 0 | SKIP 0 | PASS N ]` with N ≥ 44 (42 previous + 2 new expectations).

- [x] **Step 4: Mark this plan's checkboxes and commit the plan file**

```bash
git add planning/2026-09-14-cran-resubmission-fixes.md
git commit -m "docs(planning): record CRAN 0.1.1 resubmission plan and verification

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 9: Hand-off to the user (human-only steps)

- [x] **Step 1: Report status** — list the three commits (`git log --oneline -5`), paste the `Status: 1 NOTE` line and the NOTE body, and remind the user that the four "Related work" files are still uncommitted and belong to the other agent.
- [x] **Step 2: User decides about the foreign hunks** — either the other agent commits them, or the user asks us to commit them (`git add R/educabr2-package.R man/educabr2-package.Rd README.md vignettes/introduction.Rmd` + `docs: describe relationship with educabR`).
- [x] **Step 3: User builds the final tarball from a clean tree and uploads** — `git status --short` must be empty, then `R CMD build .` and upload `educabr2_0.1.1.tar.gz` via <https://cran.r-project.org/submit.html>, pasting `cran-comments.md` into the comment field. `git push` is pre-authorised for this repo; the CRAN upload is the user's action.
- [x] **Step 4 (optional, after acceptance):** tag `v0.1.1`; the pkgdown site (`docs/`, gitignored) is rebuilt by CI on push.

---

## Self-review

- **Spec coverage:** LaTeX `≥` WARNING+ERROR → Tasks 1–3; `educabr2-manual.tex` NOTE → consequence of Task 3, stated in Task 7; `LICENSE.md` invalid URI → Task 5 Step 3 / Task 6; misspelled words NOTE → answered in Task 7 (WORDLIST already covers them; no DESCRIPTION rewording needed); Artur Damião removal → Tasks 4, 5 (README), 6 (Rd), 7 (comment); version bump + NEWS → Task 5; resubmission comments → Task 7; end-to-end proof with the manual enabled → Task 8; other-agent safety → banner + Task 6.
- **Placeholders:** none — every edit shows before/after text and a command; the only "if" branches are the multi-agent contingencies, each with a concrete action.
- **Consistency:** version `0.1.1` used in DESCRIPTION, NEWS, README citation, cran-comments and tarball name; test file name `test-rd-latex-safe.R` used in Tasks 2, 3, 8; scratch path identical in Tasks 1, 3, 6, 8.
