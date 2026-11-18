---
title: What works and what is proposed
---

Some parts of the stack work today, and some are proposals. This page gives the state of each part on
2026-11-18, from the code of each repository on that day. A proposal here has no code yet, and its
details can change.

## The state of each part

| Part | Works today | Proposed |
|---|---|---|
| Project setup | The installer of jnterfaces: profiles, roles, tools, the record and `just install` | A lock of the exact package commits of a project |
| Languages | Profiles for Python, TypeScript and Rust. Any other language works with recipes of its own. | A profile for another language, such as Go, when several projects need it |
| Version floors | The key `programs` of the record, and the step `tools-check` | None. The floors take the place of an earlier proposal, a lock file of external tool versions. |
| Docs | The `docs` role: a smalldocs site, `docs-check`, and `docs-publish` to the branch `gh-pages` | A list of the docs that a project must have, which `just update-docs` checks |
| Commit gate | The gate, the review records, the trailer, `ci-gate` and `just ci` | A record of the checks that a project requires, so that a missing recipe fails and does not become a skip |
| Release tags | `release-check`, `just release` and the job `release` of CI | No change |
| jlog | v0.2.0: the run log, `jlog pass`, `jlog run`, and the PATH from the `.jlog` folders | jnterfaces writes `.jlog/bin` and `.jlog/environment.json` for a project |
| A new machine | Install `git`, `gh`, `just`, `uv`, `jlog`, `gest` and `jagt` by hand. jlog, jagt and gest have release binaries and an install line each. | One command that installs them |
| Tests of a new machine | `just env-lab` of jnterfaces runs `just check` with a clean environment | Fresh Linux and macOS machines, on arm64 and x86_64, that install and commit a real project |

## A new machine

Today you install each program by hand, as [Start a fresh folder](fresh-folder.md) lists. jlog, jagt and
gest have release binaries, so only the `rust` profile needs Rust.

The proposal is one command that installs `uv`, `just` and `jlog` into the home folder, and changes
no shell profile. It then checks each program at its floor. The proposal keeps two jobs apart. The machine
setup installs the programs, and the installer of jnterfaces sets up each project.

## Programs and their paths

A check of a program reads only. The installer sets `RUSTUP_AUTO_INSTALL=0` and
`UV_PYTHON_DOWNLOADS=never` for each check. With jlog 0.2.0, the installer runs each check through
`jlog run`, so a check sees the same PATH as a recipe line.

jlog 0.2.0 reads `.jlog/bin` and `.jlog/environment.json` in the folders above the current folder, and
puts them first on the PATH. It never installs a program. No tool writes these files yet, so a project
that needs a program of its own puts it there by hand.

## The commit gate

The gate works today, as [A commit's path](commit.md) tells. These gaps stay open:

- **A skip of a step.** A step that no profile, role or recipe gives is a skip, and the pass accepts it.
  So a project with no tests passes `just check`. The proposal is a list of the checks that a project
  requires, apart from the steps that the installed tools give.
- **The hooks can be skipped.** `git commit -n` skips them. The commit then has no trailer, and
  `ci-gate` fails on the pull request.
- **The trailer is a claim.** An agent could write one by hand. The review of the pull request is the
  check of the trailer.

## Tests of the whole stack

Each package tests itself, and the tests of jnterfaces run its installer on test projects. No test yet
installs the whole stack on a fresh machine and makes real commits. The proposal is a set of fresh machines for each
platform and a set of failure cases. For example, a stale review, a missing recipe or a change after
`just check` must each stop the commit.
