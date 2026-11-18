---
title: Update a project
---

A project gets new versions of the stack through `just install`. The record, `.agents/stack.json`,
saves the profiles, roles, tools and answers, so a later install needs no names. Run the update on a
branch, and commit it as a change of its own.

## The commands

| Command | What it does |
|---|---|
| `just install` | Installs the saved set again, from the clones as they are now |
| `just install --update` | Runs `git pull --ff-only` in the jnterfaces clone and in each clone of a package that the run installs, then installs |
| `just install --check` | Compares the record with the shared files and checks the steps. It changes nothing. |
| `just install --dry-run` | Checks everything and writes nothing in the project |
| `just install --clean` | Installs the last commit of each clone, without changes that are not committed |
| `just install NAME` | Turns on a role or a tool, such as `just install docs` |
| `just uninstall NAME` | Takes out a role, a tool or a profile, and keeps each file that you edited |

`--update` skips a package clone that has no upstream branch, and prints "Not updated". After an update, run
`just install --check`, stage the changes and run `just check`.

## Version floors

A floor is the lowest version of a program that an owner accepts. jnterfaces, the profiles, the roles
and the skills each name the floors of the programs that they need. The installer joins them, and the
highest floor of each program counts. It saves each floor in the key `programs` of the record.

| Owner | Floors |
|---|---|
| jnterfaces, in each project | `jlog` >=0.2.0, `just` >=1.50.0, `uv` >=0.12.13, `git` >=2.40, `gh` >=2.40 |
| the `tasker` role | `gest` >=0.6.0, whose `gest --version` must print `(rahuldave)`, and `jagt` >=0.6.3 |
| the `rust` profile | `rustup` >=1.28.0, `cargo-llvm-cov` >=0.9.1, and more for its tools |
| the `jagt-protocol` skill | `jagt` >=0.3.0 |
| the `cx` skill | `cx` >=0.1.0 |

A project adds its own programs in the key `project_programs`. The step `tools-check`, the first step
of `just check`, runs the check of each program and compares the version with its floor. It installs
and downloads nothing. So after an update raises a floor, `just check` fails on each machine with an
older program, and the message names the floor, the version found and the owner.

[The programs of a profile](https://github.com/rahuldave/jnterfaces/blob/main/docs/stack-files.md#the-programs-of-a-profile)
gives the keys of a program and the rules of a check.

## Starter files are written once

The installer writes a starter file only when the project has none. Examples are the `Justfile`,
`AGENTS.md`, `CLAUDE.md`, and the workflows `check.yml` and `release.yml` of the `tasker` role. The
starter is yours from then on, and an update does not change it. So a newer starter does not reach an
older project. Read the starter in the clone of its package, and copy the change by hand.

Other files belong to the installer. It changes a file under `.agents/just/` or `.agents/skills/` only
while the hash of the file is the hash in the record. If you edited the file, the installer names it and
leaves it. To get the new version, undo the edit or remove the file, then run `just install` again.

## The version of each package

The installer writes one record for each package, such as `.agents/jnterfaces-install.json`. It holds
the commit of the clone in `source_revision`. `source_version` holds the release tag of that commit,
or else the output of `git describe`, such as `v0.1.0-3-g1a2b3c4`.
`git diff` of these records after an update shows which package moved and to which version.

A package can need a version of another package, with the key `requires` of its `skill-package.json`,
for example `{"jnterfaces": ">=0.1.0"}`. Before it writes anything, the installer stops when a clone
has no tag or is below the floor. Then run `just install --update` to get the newer clone.
