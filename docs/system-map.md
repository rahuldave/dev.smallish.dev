---
title: System map
---

The stack has one installer, jnterfaces, and a set of packages that it installs into a project. Each
package owns one job and the docs of that job. This page names the parts and the files that hold the
choices of a project.

## Terms

| Term | Meaning |
|---|---|
| package | A repository that ships skills, recipes or config, such as jnprofile-python |
| recipe | A command of a Justfile. `just NAME` runs it. |
| role | A job, such as `tasker` or `prose`, that one package does. The name stays when the package changes. |
| profile | The setup of one language: `python`, `typescript` or `rust` |
| tool | One part of a profile, such as `lint`, with its packages, config files and recipes |
| step | A check of `just check`, such as `lint` or `prose-check` |
| agentic target | A recipe, such as `just review`, that prints a task for a fresh agent |
| the record | `.agents/stack.json`, which saves the profiles, roles, tools, steps and floors of a project |
| floor | The lowest version of a program that an owner accepts, such as `>=1.50.0` for `just` |
| starter file | A file that the installer writes once, when the project has none. It is yours from then on. |

## The job of each package

| Package | Its job | Not its job |
|---|---|---|
| [jnterfaces](https://rahuldave.com/jnterfaces/) | The installer, the `just`, `cx` and `jagt-protocol` skills, the steps of `just check`, `tools-check`, the docs role | The rules of one language |
| [jnprofile-python](https://rahuldave.com/jnprofile-python/), [-typescript](https://rahuldave.com/jnprofile-typescript/), [-rust](https://rahuldave.com/jnprofile-rust/) | The tools, recipes and config of one language, and `<profile>::version` | The commit policy |
| [agent_gest_git_skills](https://rahuldave.com/agent_gest_git_skills/) | The `tasker` role: the `g*` skills, the agent hooks, the Git hooks, the commit gate, the review targets, `release-check` and `just release` | The steps of a language |
| [jlog](https://rahuldave.com/jlog/) | The recipe shell, the run log, `jlog step`, `jlog skip`, `jlog pass` and the PATH of `.jlog` folders | Which steps a project needs |
| [gest](https://rahuldave.com/gest/) | Tasks, iterations, artifacts and notes | Proof that a check ran |
| [jagt](https://rahuldave.com/jagt/) | The `AGENT_TASK` and `AGENT_RESULT` packets, and their nonces | The policy of the project |
| [cx](https://rahuldave.com/cx/) | File stages that run again only when an input, an output or the command changes | A test result |
| [nossaifd](https://rahuldave.com/nossaifd/) | The `prose` role: the writing guide, `check.py`, the declaude skill and `just prose-check` | Which pages a project must have |
| [smalldocs](https://docs.smallish.dev/) | The docs sites, `smalldocs check` and the API pages | The text of the pages |

## The files of a project

The installer writes these files, and the tools read them:

| File | Who writes it | Who reads it |
|---|---|---|
| `Justfile` | The installer once, then you | `just` |
| `.agents/install.just` | jnterfaces | The `Justfile`, which imports it. It gives `just install`. |
| `.agents/just/` | The installer, at each run | `just`. Commit it, because a clone without it has no recipes of the profiles. |
| `.agents/stack.json` | The installer | `just install`, `tools-check`, `jlog pass` and the commit gate. The installer writes its list `ci` into the recipe `just ci`. |
| `.agents/<package>-install.json`, or the record name of the catalog, such as `gest-git-install.json` | The installer | The installer, which keeps the commit, the version and the hash of each file it copied |
| `.agents/log/` | jlog and the record scripts | The commit gate. Git ignores the folder. |
| `.pre-commit-config.yaml` | The `tasker` role | The Git hooks of the pre-commit framework |

[The files of the stack](https://rahuldave.com/jnterfaces/stack-files.html) gives each key of each file.

## How the installer joins the parts

The installer reads its catalog, `stack.json` of jnterfaces, then the `skill-package.json` of each
package and the `profile.json` of each profile. It copies the skills, writes one recipe module for each
profile, and adds its part to each shared file, such as `.gitignore`. The record keeps each part, so
`just uninstall` takes out only what the installer added.

The installer never overwrites a file that you edited. It names the file and installs the rest.
[How the stack fits together](https://rahuldave.com/jnterfaces/stack-guide.html) builds a project in
layers and tells each rule.
