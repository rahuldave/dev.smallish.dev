---
title: Releases and versions
---

jnterfaces, the three profiles, agent_gest_git_skills and each project with the `tasker` role get
semantic version tags `vX.Y.Z`. CI makes each tag after a push to `main`. Nobody tags by hand, and nobody moves or deletes a
pushed tag.

## Who makes the tag

The `tasker` role writes the starter workflow `.github/workflows/release.yml`. It runs on each push to
`main`:

1. The job `check` runs `just check` on the pushed commit, with the whole history and the tags.
2. When the check passes, the job `release` runs `just release`. It makes the annotated tag on the
   commit, pushes the tag and checks it with `git ls-remote`.

The job `release` is the only job that can write to the repository. No agent runs in it. A push that
needs no release, such as a change of only the docs, makes no tag. The script is
`release_tag.py` of the gpa skill of agent_gest_git_skills.

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
