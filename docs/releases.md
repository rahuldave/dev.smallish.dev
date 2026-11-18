---
title: Releases and versions
---

jnterfaces, the three profiles, agent_gest_git_skills, cx, jlog, gest and each project with the
`tasker` role get semantic version tags `vX.Y.Z`. CI makes each tag after a push to `main`. Nobody tags
them by hand, and nobody moves or deletes a pushed tag. jagt is the exception, because its maintainer
pushes each tag by hand.

## Who makes the tag

The `tasker` role writes the starter workflow `.github/workflows/release.yml`. It runs on each push to
`main`:

1. The job `check` runs `just check` on the pushed commit, with the whole history and the tags.
2. When the check passes, the job `release` runs `just release`. It makes the annotated tag on the
   commit, pushes the tag and checks it with `git ls-remote`.

In the starter workflow, the job `release` is the only job that can write to the repository. No agent runs in it. A push that
needs no release, such as a change of only the docs, makes no tag. The script is
`release_tag.py` of the gpa skill of agent_gest_git_skills.

jnterfaces, the three profiles, agent_gest_git_skills, cx, jlog and gest have workflows of their own,
with the same job `release` after their checks. nossaifd, sklanes and jagt have no job `release`. cx, jlog and gest keep a copy of `release_tag.py`. In jnterfaces and agent_gest_git_skills, CI
runs only `just check` or steps of it, so a pass of `just check` on your machine is the same check.

## Release binaries

cx, jlog, gest and jagt ship a binary for each platform with each release, so a machine needs no Rust
to install them. The workflow of cx is the model for the others.

1. **The job `binaries`** runs after the job `release` on each push to `main`. When the commit has no
   release tag, the job skips its steps and passes. A
   tag that the job `release` pushes starts no other workflow, so the build runs in the same workflow.
   A matrix builds four targets:

   | Target | Runner |
   |---|---|
   | `aarch64-apple-darwin`, macOS on arm64 | `macos-15` |
   | `x86_64-apple-darwin`, macOS on x86_64 | `macos-15`, as a cross build |
   | `x86_64-unknown-linux-musl`, Linux on x86_64 | `ubuntu-24.04` |
   | `aarch64-unknown-linux-musl`, Linux on arm64 | `ubuntu-24.04-arm` |

   GitHub retired the runner `macos-13`, so the arm64 runner `macos-15` builds the Intel binary. The runner
   cannot run that binary, so the job checks its architecture. The Linux builds use musl, so each
   binary is static and runs on any distribution. Each build runs `just dist <target>`, which writes
   `dist/<bin>-<target>.tar.gz` and its hash, `dist/<bin>-<target>.tar.gz.sha256`.
2. **The job `publish`** runs after all four builds. It puts the eight files on the GitHub release of
   the tag. The job `binaries` can only read, so `release` and `publish` are the only jobs that can
   write.

jagt has no job `release`. A tag that its maintainer pushes starts its workflow `release.yml`, which
builds the same four targets on `macos-latest` and the Linux runners, without `just dist`, and
publishes them the same way.

Each of the four repositories has `scripts/install.sh`. It downloads the archive for the machine and its
`.sha256`, and stops when the hash does not match. It puts the binary in `~/.local/bin`, or the folder
of `--dir`. It writes the new binary next to the old one, then renames it over the old one in one step.
A copy over a running binary fails on Linux, and macOS can stop a signed binary that changed in place.

With no `--tag`, `install.sh` installs the latest release.
[Start a fresh folder](fresh-folder.md#what-the-machine-needs) gives the install line of each tool.

## How the number is chosen

The last tag is the newest tag `vX.Y.Z` that is an ancestor of the commit. The script reads the
conventional commits since that tag, and the largest bump counts:

| Commit message | Bump |
|---|---|
| `<type>!:`, such as `feat!:`, or a line `BREAKING CHANGE:` | MAJOR, or MINOR below `1.0.0` |
| `feat` | MINOR |
| `fix`, `perf`, `refactor`, another type, or a message that is not conventional | PATCH |
| `docs`, `test`, `ci`, `chore`, `style` | No release |

With no tag yet, the first tag is `v0.1.0`.

## The version of the manifest

A manifest is the file that names the package and its version, such as `pyproject.toml`,
`package.json` or `Cargo.toml`. Each profile gives the recipe `<profile>::version`, which prints the
version of its manifest, or nothing:

| Recipe | Reads |
|---|---|
| `python::version` | `[project].version` of `pyproject.toml` |
| `typescript::version` | `version` of `package.json` |
| `rust::version` | the version of `Cargo.toml` |

When a profile prints a version, the tag is that version with a `v` in front. The script fails when
two profiles print different versions. It also fails when the version is below the last tag, or below
the bump that the commits ask for. So when the manifest has a version, a pull request with a `feat`
commit must also raise it.

## Check before the merge

`release-check` is the second step of `just check`. It runs the script with `--check` and prints the
next tag. It needs no network. So a commit that needs a higher manifest version fails on your machine,
before the merge. In a shallow checkout or with no tag yet, it says so and passes.

`just release --dry-run` prints the tag and changes nothing.

## Floors in the record

A release raises a version, and a floor names the lowest version that a project accepts. The floors of
the programs, such as `jlog` >=0.2.0, are in the key `programs` of `.agents/stack.json`, and
`tools-check` checks them. A package names the versions of other packages that it needs with
`requires` in its `skill-package.json`. [Update a project](update.md) tells how both work.

The "Release tags" section of the
[delivery workflow](https://github.com/rahuldave/agent_gest_git_skills/blob/main/docs/integration_delivery_workflow.md#release-tags)
gives each rule and each error.
