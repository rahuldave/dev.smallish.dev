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
| `gest` | 0.6.0 | The `g*` skills of the `tasker` role, which is on by default. It must be the fork of rahuldave, whose `gest --version` prints `(rahuldave)`. |
| `jagt` | 0.6.3 | The review packets of the `tasker` role. An older jagt can save the review packet where the commit gate does not read it, in a submodule or a linked worktree. |
| `cx` | 0.1.0 | The `cx` skill only, which is off by default. Install v0.2.3, the latest release. |
| `rustup` | 1.28.0 | The `rust` profile only |

jlog, jagt, gest and cx have release binaries for macOS and Linux, on arm64 and x86_64. Each install line
downloads the binary, checks its SHA-256 and puts it in `~/.local/bin`. Put that folder on your PATH.
The install of jlog also copies its plugins to `~/.local/share/jlog/plugins`. When `uv` is there, it
makes their environments, so install `uv` first.

Each line takes `install.sh` from the release that `--tag` names. The line of jagt installs v0.6.4, and
the floor of jagt stays at 0.6.3.

```bash
curl -fsSL https://raw.githubusercontent.com/rahuldave/jlog/v0.3.0/scripts/install.sh | sh -s -- --tag v0.3.0
curl -fsSL https://raw.githubusercontent.com/rahuldave/jagt/v0.6.4/scripts/install.sh | sh -s -- --tag v0.6.4
curl -fsSL https://raw.githubusercontent.com/rahuldave/gest/v0.6.0/scripts/install.sh | sh -s -- --tag v0.6.0
curl -fsSL https://raw.githubusercontent.com/rahuldave/cx/v0.2.3/scripts/install.sh | sh -s -- --tag v0.2.3
```

Install cx only when you turn on the `cx` skill.

To build jlog from source instead, clone <https://github.com/rahuldave/jlog>, run
`git checkout v0.3.0`, then run `just install` in the clone. To build jagt from source, run
`cargo install --locked --git https://github.com/rahuldave/jagt --tag v0.6.4 jagt`. To build gest from
source, clone <https://github.com/rahuldave/gest>, run `git checkout v0.6.0`, then run
`cargo install --locked --path .` in the clone. To build cx from source, run
`cargo install --locked --git https://github.com/rahuldave/cx --tag v0.2.3 cx`. A build from source needs Rust from <https://rustup.rs/>.

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

The `docs` role writes a smalldocs site in `docs/`. The theme of a new site is Atelier, with a light
mode and a dark mode. A site with its own config and another theme keeps that theme, and gets no theme
files.

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
