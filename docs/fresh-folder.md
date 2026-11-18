---
title: Start a fresh folder
---

A new project starts in an empty folder with `git init`. The installer of jnterfaces then writes the
recipes, the skills and the record. The first install runs from a clone of jnterfaces, because the folder
has no `just install` yet. After that, `just install` does each change.

[Start a Python, TypeScript or Rust project](https://rahuldave.com/jnterfaces/new-project.html) gives
each step with examples. This page gives the order and the choices.

## What the machine needs

Install these programs once on each machine. The installer stops and writes nothing when a program of
the table is missing or below its floor. It installs the other tools of a profile or a role itself,
such as `cargo-llvm-cov` or `pre-commit`.

| Program | Floor | Why |
|---|---|---|
| `git` | 2.40 | Each project and each clone of a package |
| `gh` | 2.40 | Pull requests, the checks of CI, and `docs-publish` |
| `just` | 1.50.0 | Every recipe |
| `uv` | 0.12.13 | The installer, Python, the Python tools, and Node for TypeScript |
| `jlog` | 0.2.0 | The shell of each recipe that the installer writes |
| `gest` | 0.5.6 | The `g*` skills of the `tasker` role, which is on by default |
| `jagt` | 0.6.1 | The review targets of the `tasker` role. The installer checks `jagt` only with the `jagt-protocol` skill, at 0.3.0. A record matches the gate from 0.6.1 on. |
| `rustup` | 1.28.0 | The `rust` profile only |

jlog has no binary release. To install it, clone <https://github.com/rahuldave/jlog>, run
`git checkout v0.2.0`, then run `just install` in the clone. Its install builds with `cargo`, so every
machine needs Rust from <https://rustup.rs/>, also for a Python project.

No single command sets up a new machine yet. [What works and what is proposed](status.md) tells the proposal.

## Choose the setup

```{mermaid}
flowchart TD
    start[Fresh folder] --> kind{What will it hold?}
    kind -->|Code| language{Which language?}
    kind -->|Text, notes or a book| text[prose role]
    kind -->|Spreadsheets or data| data[prose role and your own check recipes]
    language -->|Python, TypeScript or Rust| profile[--profile NAME]
    language -->|Two of them| two[--profile python,typescript]
    language -->|Another language| custom[tasker prose and your own recipes]
    profile --> install[Run the installer from the clone]
    two --> install
    custom --> install
    text --> install
    data --> install
    install --> check[Stage the files and run just check]
```

| Project | Names for the first install | What you add |
|---|---|---|
| Python | `--profile python` | The code and the tests |
| TypeScript | `--profile typescript` | The code and its tests in `src/` |
| Rust | `--profile rust` | `Cargo.lock` from `just setup`, a doc line and a test |
| Python and TypeScript | `--profile python,typescript` | The layout of both parts |
| Go or another language | `tasker prose` | Recipes for `lint` and `test` that end with `jlog step NAME` |
| Text, notes or a book | `prose` | The pages. Add `docs` for a smalldocs site. |
| Spreadsheets or data | `prose` | A recipe that checks the data, such as its columns or totals |

Add `--defaults` to take the default roles and answers with no questions. A command that names only
roles turns on those roles and asks about no other role. No profile exists for Go, so `--profile go` fails.

## Install

Clone jnterfaces once into the folder of package clones. The default folder is
`~/.local/share/skill-packages`. Set `SKILL_PACKAGES_DIR` in your shell profile to use another folder.

```bash
git clone https://github.com/rahuldave/jnterfaces "${SKILL_PACKAGES_DIR:-$HOME/.local/share/skill-packages}/jnterfaces"
```

Make the folder, then run the installer from the clone:

```bash
mkdir app && cd app && git init
uv run "${SKILL_PACKAGES_DIR:-$HOME/.local/share/skill-packages}/jnterfaces/scripts/install_stack.py" --profile python
```

The installer clones each other package that it needs into the same folder. It writes the starter
`Justfile`, `AGENTS.md`, `CLAUDE.md`, the files under `.agents/`, and the manifest, such as
`pyproject.toml`, when the folder has none.

## The first `just check`

`just check` runs these steps in this order, and ends with `jlog pass`. With the answer
`integration=verify`, it leaves out `integration`.

```text
tools-check release-check fmt-check lint typecheck test integration coverage-check docstring-check docs-check prose-check diff-check
```

A step that nothing gives logs a skip. So a new project with no code passes. A skip proves nothing
about the code, so add the real checks before you trust a pass.

`jlog pass` writes a pass only when the worktree has no unstaged change and no untracked file. Format
the code with `just fmt` when a profile gives it, then stage the files:

```bash
git add --all
just install --check
just check
```

If a step fails, fix it, stage the fix and run `just check` again. Commit `.agents/`, `.claude/`,
`.codex/`, `AGENTS.md`, `CLAUDE.md`, the `Justfile`, the workflows and the config files.
[A commit's path](commit.md) tells what the Git hooks then check.

## Another language

A recipe of the `Justfile` with the name of a step takes the place of that step. It must end with
`jlog step NAME`, and it must not be a shebang recipe, because jlog does not see its lines. For
example, a Go project can give two steps:

```just
lint:
    go vet ./...
    jlog step lint

test:
    go test ./...
    jlog step test
```

Run `just install` after you add the recipes, then stage them and run `just check`. Make a profile
package only when several projects need the same setup.
