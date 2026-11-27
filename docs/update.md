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
| `just install --update` | Moves the jnterfaces clone and each clone of a package that the run uses to its latest release, then installs |
| `just install --check` | Compares the record with the shared files and checks the steps. It changes nothing. |
| `just install --dry-run` | Checks everything and writes nothing in the project |
| `just install --clean` | Installs the last commit of each clone, without changes that are not committed |
| `just install NAME` | Turns on a role or a tool, such as `just install docs` |
| `just uninstall NAME` | Takes out a role, a tool or a profile, and keeps each file that you edited |

`just uninstall docs` keeps the pages and the theme files, because they are yours. While a theme file
stays, the installer keeps the line `_extensions/** -whitespace` in `docs/.gitattributes`, so
`git diff --check` accepts the line ends of the theme. Delete the theme, and the next run takes out the
line.

Since jnterfaces v0.4.1, the latest release of a package is the highest release tag `vX.Y.Z` on the
default branch of its remote. A commit after that tag is not released, so `--update` does not install it.
A clone with commits after the latest release moves back to the release, when the remote branch has
each of these commits. An older jnterfaces pulled each clone to its newest commit, so the first update
with v0.4.1 can move a clone back. A package with no release tag gets the newest commit of the remote
branch, and the run says so.

The installer never discards a local change. These clones stop the run, and the message names the clone:

- A clone with changes to tracked files that are not committed.
- A clone with an untracked or ignored file where the release adds a file or a folder.
- A clone that cannot fast-forward. Its branch and the remote branch each have commits that the other
  does not have.
- A clone whose remote the installer cannot read, for example with no network.

These clones stay as they are, and the run prints "Not updated":

- A clone on a branch that is not the default branch of its remote, or on a branch with no upstream
  branch.
- A clone with its own commits on top of the remote branch.
- A clone that does not know the default branch of its remote. The message gives the command that sets
  it.
- A clone that you checked out at a tag or a commit. So, to pin a package, check out that tag in its
  clone, for example `git -C CLONE checkout v0.4.3`.

The jnterfaces clone moves first, then the profile clones, then the role clones. A clone that stops the
run does not undo the clones that moved before it, but the installer writes nothing in the project.
[How an install works](https://rahuldave.com/jnterfaces/stack-guide.html#how-an-install-works) gives
all the rules. After an update, run `just install --check`, stage the changes and run `just check`.

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

Since jnterfaces v0.3.0 and agent_gest_git_skills v0.4.0, `tools-check` also checks the Git hooks of the
`tasker` role. A new clone of a project has no hooks, so `just check` fails there. Run `just install`, which runs `pre-commit install`.
When `CI` is set, `tools-check` does not check the hooks.

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
has no tag or is below the floor. Then run `just install --update` to move the clone to its latest
release. A clone that `--update` does not move, such as a clone at a tag, needs a newer tag checked out
by hand.
