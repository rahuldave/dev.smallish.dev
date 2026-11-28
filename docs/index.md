---
title: smallish dev
---

smallish dev is a stack that sets up and checks repositories where people and AI agents work together.
It gives every repository the same `just` commands and logs each command line that runs. Before a commit
lands, a Git hook verifies that the staged files passed their checks and reviews.

Each tool in the stack has its own repository and documentation site. This site explains how the tools
fit together as one system and links to each tool for the details.

## Parts of the stack

Most repositories repeat the same daily work, such as dependency installs, tests, docs and releases.
Without a shared interface, each project has its own scripts, and an AI agent can claim that checks
passed without proof. smallish dev solves both problems with shared recipes, a run log, local agent
reviews and writing tools.

jnterfaces installs the command surface across languages. You pick a language profile
(`jnprofile-python`, `jnprofile-typescript` or `jnprofile-rust`) and optional roles (`tasker`, `prose` or
`docs`). `just install` copies the recipes and agent skills into the repository, and
`just install --update` updates them to newer releases. Every project then uses the same commands, such
as `just setup`, `just fmt`, `just lint`, `just test` and `just check`.

jlog is the shell for every `just` recipe. It runs each line and writes the command, exit code and tree
hash of the worktree to `.agents/log/just.jsonl`. `just check` runs only deterministic tools, with the
Python script `check.py` for `prose-check`, and ends with `jlog pass`. Before a commit lands, the Git
hook of agent_gest_git_skills checks that the staged tree matches that pass.

Some checks need judgment rather than a linter, such as an adversarial code review or a prose revision.
Those checks run through separate local agentic recipes (`just review`, `just test-review`,
`just update-docs` and `just prose`) on your machine and never in CI. jagt formats each task as an
`AGENT_TASK` packet for a fresh agent and checks the returned `AGENT_RESULT` before the commit gate
accepts it. agent_gest_git_skills also gives the `g*` workflow skills, local tasks in gest and sync for
GitHub issues through `gh`.

nossaifd gives the plain-English writing guide, `check.py` and the `declaude` revision skill. smalldocs
builds the documentation site for each tool and this site too. cx is optional and caches slow
file-to-file recipe steps so that they run again only when their inputs change.

## Flow from install to commit

```{mermaid}
flowchart LR
    you[You or an agent] --> just[just: the recipes]
    installer[jnterfaces installer] -->|writes| recipes[Justfile and .agents/]
    installer -->|copies from| packages[profiles, g* skills, nossaifd]
    just -->|each line through| jlog[jlog: the run log]
    jlog --> steps[ruff, cargo, biome, smalldocs, check.py]
    just -->|review, update-docs, prose| packet[AGENT_TASK packet]
    packet --> agent[A fresh agent]
    agent -->|AGENT_RESULT, checked by jagt| records[Review records]
    commit[git commit] --> gate[Commit gate]
    gate -->|reads| jlog
    gate -->|reads| records
    skills[g* skills] --> gest[gest: the tasks]
```

The diagram moves from setup on the left to a gated commit on the right:

1. `jnterfaces` writes the `Justfile`, `.agents/` recipes, skills and config from the package clones.
2. `just` runs each recipe line through `jlog`, which logs the run and writes a `jlog pass` when
   `just check` finishes clean.
3. For agent commits, recipes such as `just review` hand a packet to a fresh agent. `jagt` checks the
   reply before the hook saves a record.
4. On `git commit`, the Git hooks check the `jlog` pass and any required review records without a second
   `just check`. The `commit-msg` hook then runs `just release-check` and stamps the `Commit-Gate:`
   trailer.

[System map](system-map.md) lists the exact terms, package boundaries and project files.

## Tools in the stack

| Tool | What it does | Site |
|---|---|---|
| jnterfaces | Installer, `just install`, roles, profiles and the `just check` pipeline | [rahuldave.com/jnterfaces](https://rahuldave.com/jnterfaces/) |
| agent_gest_git_skills | `tasker` role: `g*` skills, commit gate, agentic review targets and release tags | [rahuldave.com/agent_gest_git_skills](https://rahuldave.com/agent_gest_git_skills/) |
| jlog | Recipe shell, run log, `jlog run` and the `jlog pass` proof | [rahuldave.com/jlog](https://rahuldave.com/jlog/) |
| gest | Local task tracker for the `g*` workflow skills | [rahuldave.com/gest](https://rahuldave.com/gest/) |
| jagt | `AGENT_TASK` and `AGENT_RESULT` packet renderer and validator | [rahuldave.com/jagt](https://rahuldave.com/jagt/) |
| nossaifd | `prose` role: plain-English writing guide, `check.py` and the `declaude` skill | [rahuldave.com/nossaifd](https://rahuldave.com/nossaifd/) |
| smalldocs | Static docs site builder used by the `docs` role and this site | [docs.smallish.dev](https://docs.smallish.dev/) |
| cx | Optional incremental runner that skips unchanged file-to-file steps | [rahuldave.com/cx](https://rahuldave.com/cx/) |
| jnprofile-python | Python profile: ruff, ty and pytest, managed through uv | [rahuldave.com/jnprofile-python](https://rahuldave.com/jnprofile-python/) |
| jnprofile-typescript | TypeScript profile: Biome, tsc and the Node test runner, through uv | [rahuldave.com/jnprofile-typescript](https://rahuldave.com/jnprofile-typescript/) |
| jnprofile-rust | Rust profile: rustfmt, clippy, cargo-llvm-cov and docstring checks | [rahuldave.com/jnprofile-rust](https://rahuldave.com/jnprofile-rust/) |

## The pages

| Page | What it covers |
|---|---|
| [System map](system-map.md) | Terms, package boundaries and the files in a project |
| [Start a new project](fresh-folder.md) | One-time machine setup, choosing profiles and roles, and the first `just check` |
| [Bring an existing project in](existing-project.md) | Adding jnterfaces to an existing repository, resolving recipe clashes and updating CI |
| [Update a project](update.md) | `just install --update`, `--check`, version floors and starter files |
| [A commit's path](commit.md) | Deterministic checks, agentic targets, `jlog pass`, commit gate and CI |
| [Releases and versions](releases.md) | Automated release tags, release binaries, manifest versions and floors |
| [What works and what is proposed](status.md) | Current release tags and the state of each part of the stack |
