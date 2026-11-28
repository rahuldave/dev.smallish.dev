---
title: Start a new project
---

A new project starts in an empty Git repository. You install the base programs on your machine once,
clone `jnterfaces` once, and run its installer inside the new folder. After that, `just install` manages
updates, roles and tools inside the project.

If your repository already has code, a `Justfile`, `AGENTS.md` or CI workflows, read
[Bring an existing project in](existing-project.md) instead. For language-specific walkthroughs with
sample code and tests, see
[Start a Python, TypeScript or Rust project](https://rahuldave.com/jnterfaces/new-project.html).

## Set up your machine once

Install these programs once on each machine. Before it writes any file, the installer checks every
required program against its version floor and stops if one is missing or too old. You do not install
role and profile tools such as `pre-commit` or `cargo-llvm-cov` by hand, because the installer adds them.

| Program | Floor | Why |
|---|---|---|
| `git` | 2.40 | Project history and package clones |
| `gh` | 2.40 | Pull requests, CI checks and `docs-publish` |
| `just` | 1.50.0 | Runs every project recipe |
| `uv` | 0.12.13 | Runs the installer, Python tools and Node for TypeScript |
| `jlog` | 0.2.0 | Recipe shell that logs every line and records `jlog pass` |
| `gest` | 0.6.0 | Task tracker for the `tasker` role; `gest --version` must print `(rahuldave)` |
| `jagt` | 0.6.3 | Renders and checks review packets for the `tasker` role |
| `cx` | 0.1.0 | Optional `cx` skill only, off by default; install `v0.2.3` |
| `rustup` | 1.28.0 | Required for the `rust` profile only |

`jlog`, `jagt`, `gest` and `cx` have release binaries for macOS and Linux on arm64 and x86_64.
Each install script downloads the archive, checks its SHA-256 hash and puts the binary in `~/.local/bin`.
Add `~/.local/bin` to your `PATH`.

Install `uv` before `jlog`. The install script of `jlog` copies its plugins to `~/.local/share/jlog/plugins`
and creates their environments with `uv` when `uv` is on your `PATH`.

Each command pulls `install.sh` from the tag that `--tag` names. The `jlog` command installs `v0.5.0`
(the floor stays at `0.2.0`), and the `jagt` command installs `v0.6.4` (the floor stays at `0.6.3`).

```bash
curl -fsSL https://raw.githubusercontent.com/rahuldave/jlog/v0.5.0/scripts/install.sh | sh -s -- --tag v0.5.0
curl -fsSL https://raw.githubusercontent.com/rahuldave/jagt/v0.6.4/scripts/install.sh | sh -s -- --tag v0.6.4
curl -fsSL https://raw.githubusercontent.com/rahuldave/gest/v0.6.0/scripts/install.sh | sh -s -- --tag v0.6.0
curl -fsSL https://raw.githubusercontent.com/rahuldave/cx/v0.2.3/scripts/install.sh | sh -s -- --tag v0.2.3
```

Install `cx` only if you plan to turn on the `cx` skill.

To build from source instead, install Rust from <https://rustup.rs/> and run the command for each tool:

| Tool | Build from source |
|---|---|
| jlog | Clone <https://github.com/rahuldave/jlog>, run `git checkout v0.5.0`, then run `just install` |
| jagt | `cargo install --locked --git https://github.com/rahuldave/jagt --tag v0.6.4 jagt` |
| gest | Clone <https://github.com/rahuldave/gest>, run `git checkout v0.6.0`, then run `cargo install --locked --path .` |
| cx | `cargo install --locked --git https://github.com/rahuldave/cx --tag v0.2.3 cx` |

Finish machine setup on Linux and macOS:

- **GitHub access.** Run `gh auth login` so `gh` can inspect repositories and open pull requests. If your
  repositories use SSH remotes, add an SSH key to GitHub as well.
- **System Rust packages on Linux.** Distributions such as Arch Linux and Omarchy ship a system `rust`
  package (`extra/rust`) with standalone `/usr/bin/cargo` and `/usr/bin/rustc` binaries. That package
  shadows a `rustup.rs` install in `~/.cargo/bin` and ignores `rust-toolchain.toml`. Replace it with
  `sudo pacman -S rustup` and then run `rustup default stable`, so `/usr/bin/cargo` and `/usr/bin/rustc`
  become `rustup` proxies.

Clone only `jnterfaces` into your package cache. Do not clone `agent_gest_git_skills`, `nossaifd` or the
`jnprofile-*` repositories by hand. The default folder is `~/.local/share/skill-packages`. To use another
folder, set `SKILL_PACKAGES_DIR` in your shell profile:

```bash
git clone https://github.com/rahuldave/jnterfaces "${SKILL_PACKAGES_DIR:-$HOME/.local/share/skill-packages}/jnterfaces"
```

No single bootstrap command sets up a machine yet. [What works and what is proposed](status.md) tracks the
proposal.

## Pick a profile and roles

A profile sets up one language (`python`, `typescript` or `rust`). Roles add tools that work across
languages, such as commit gates (`tasker`), plain-English writing checks (`prose`) and a smalldocs site
(`docs`).

```{mermaid}
flowchart TD
    start[Empty folder] --> kind{What will it hold?}
    kind -->|Code| language{Which language?}
    kind -->|Docs, notes or a book| text[prose, docs and optional tasker]
    kind -->|Spreadsheets or data| data[prose and custom check recipes]
    language -->|Python, TypeScript or Rust| profile[--profile NAME]
    language -->|Two languages| two[--profile python,typescript]
    language -->|Another language| custom[tasker prose and custom recipes]
    profile --> install[Run install_stack.py]
    two --> install
    custom --> install
    text --> install
    data --> install
    install --> check[Stage files and run just check]
```

| Project | Arguments for first install | What you add next |
|---|---|---|
| Python | `--profile python` | Code and tests |
| TypeScript | `--profile typescript` | Code and tests in `src/` |
| Rust | `--profile rust` | `Cargo.lock` from `just setup`, doc comments and a test |
| Python and TypeScript | `--profile python,typescript` | Layout for both languages |
| Go or another language | `tasker prose` | Custom `lint` and `test` recipes ending with `jlog step NAME` |
| Docs site, notes or book | `tasker prose docs` (or `prose docs`) | Pages in `docs/` |
| Spreadsheets or data | `prose` | Check recipes for columns, schemas or totals |

The `docs` role creates a smalldocs site in `docs/` with the Atelier theme (light and dark modes). If
`docs/_smalldocs.yml` already sets another theme, the installer keeps that theme and copies no theme
files.

At a terminal, the installer asks which roles to turn on. It then asks setup questions (`issues`,
`integration`, `tasker`, `review-model`, and `docs-publish` when `docs` is on). Pass `--defaults` to
accept the default roles and answers without prompts, and add `--answer KEY=VALUE` to override any single
answer. When a command names only roles (such as `prose docs`), the installer turns on those roles and no
others. No profile exists for Go, so `--profile go` fails.

## Install into the new folder

Create the folder, initialize Git and run `install_stack.py` from your `jnterfaces` clone. If you want
the installer to pull the latest release tag of each package clone first, add `--update`:

```bash
mkdir app && cd app && git init
uv run "${SKILL_PACKAGES_DIR:-$HOME/.local/share/skill-packages}/jnterfaces/scripts/install_stack.py" --update --profile python
```

On this first run, `install_stack.py` clones `agent_gest_git_skills`, `nossaifd` and each needed profile
into `~/.local/share/skill-packages` (or `SKILL_PACKAGES_DIR`). It writes the starter `Justfile`,
`AGENTS.md`, `CLAUDE.md`, GitHub workflows, `.agents/` files and the language manifest (such as
`pyproject.toml`) when none exists. With `tasker`, it also installs `pre-commit` and registers the Git
hooks in `.git/hooks/`.

Open `AGENTS.md` after install. Replace each `<replace-me>` placeholder with your project name, folders,
default branch and commands.

## Run your first `just check` and commit

`just check` runs every deterministic step in this order and ends with `jlog pass` (with
`integration=verify`, it leaves out `integration`):

```text
tools-check release-check ci-gate fmt-check lint typecheck test integration coverage-check docstring-check docs-check prose-check diff-check
```

A step with no provider logs a skip, so an empty project passes. A skip proves nothing about future code,
so add real tests and checks before you rely on a pass.

`jlog pass` records a pass only when the worktree has no unstaged changes and no untracked files. If your
profile includes `just fmt`, format any generated code first. Then stage all files and run the checks:

```bash
git add --all
just install --check
just check
```

If any step fails, fix it and stage the fix, then run `just check` again. For an agent commit with
`tasker` on, run targets that edit files first (`just update-docs`, then `just prose`) and the review
targets last (`just review`, and `just test-review` if code changed). If you edit files to fix a finding,
stage the fix and re-run any affected target before the final `just check`. Manual `nossaifd` steps do
not write the `prose` record that the commit gate expects. [A commit's path](commit.md) explains the full
order and what the Git hooks check.

Commit `.agents/`, `.claude/`, `.codex/`, `AGENTS.md`, `CLAUDE.md`, `Justfile`, `.pre-commit-config.yaml`,
`.gitignore`, `.worktreedisposable`, the starter workflows and the language manifest and config files.
When someone else clones the repository later, they run `just install` to install the Git hooks, plus
`just setup` when a language profile or project defines it.

## Add steps for another language

A recipe in your `Justfile` with the name of a step replaces the default skip for that step. It must end
with `jlog step NAME` and must not start with a `#!` shebang line, because `jlog` cannot inspect lines
inside a shebang script. For example, a Go project can define `lint` and `test`:

```just
lint:
    go vet ./...
    jlog step lint

test:
    go test ./...
    jlog step test
```

After you add the recipes, run `just install` and stage the changes, then run `just check`. Build a
dedicated profile package only when several repositories share the same toolchain setup.
