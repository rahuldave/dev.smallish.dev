---
title: smallish dev
---

The smallish dev tools set up a project so that a person and an AI agent work the same way. Every
command of the project is a recipe of `just`, a command runner. Every recipe line goes into a run log.
Before a commit, a Git hook reads that log, and for a commit by an agent the records of the reviews. It
stops a commit that has no proof of its checks.

Each tool has its own repository and its own site. This site tells how the tools fit together, and it
links to the site of each tool for the details.

## Which tool calls which

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

The diagram reads from left to right:

- **The installer** of jnterfaces writes the recipes and the files under `.agents/`. It copies them
  from the packages, which are the profiles, the `g*` skills and nossaifd.
- **just** runs each recipe, and **jlog** runs each line of it and logs the line.
- **An agentic recipe**, such as `just review`, prints a task for a fresh agent. The agent returns a
  result, and jagt checks the result before the record is saved.
- **The commit gate** reads the run log, and for a commit by an agent the records. It runs no check
  itself.

[The system map](system-map.md) gives the terms and the files that hold each choice.

## The tools

| Tool | What it does | Site |
|---|---|---|
| jnterfaces | The installer, `just install`, the roles, the profiles and the steps of `just check` | [rahuldave.com/jnterfaces](https://rahuldave.com/jnterfaces/) |
| jnprofile-python | The Python profile: ruff, ty and pytest, with uv | [rahuldave.com/jnprofile-python](https://rahuldave.com/jnprofile-python/) |
| jnprofile-typescript | The TypeScript profile: Biome, tsc and the Node test runner, with Node through uv | [rahuldave.com/jnprofile-typescript](https://rahuldave.com/jnprofile-typescript/) |
| jnprofile-rust | The Rust profile: rustfmt, clippy, cargo-llvm-cov and the doc checks | [rahuldave.com/jnprofile-rust](https://rahuldave.com/jnprofile-rust/) |
| agent_gest_git_skills | The `g*` skills, the commit gates, the review targets and the release tags | [rahuldave.com/agent_gest_git_skills](https://rahuldave.com/agent_gest_git_skills/) |
| jlog | The shell of each recipe, the run log, `jlog run` and the pass of `just check` | [rahuldave.com/jlog](https://rahuldave.com/jlog/) |
| gest | The task tracker of the `g*` skills | [rahuldave.com/gest](https://rahuldave.com/gest/) |
| jagt | The packets that hand a task to an agent and return its result | [rahuldave.com/jagt](https://rahuldave.com/jagt/) |
| cx | Recipe lines that run again only when their files change | [rahuldave.com/cx](https://rahuldave.com/cx/) |
| nossaifd | The writing guide and its checker, `check.py` | [rahuldave.com/nossaifd](https://rahuldave.com/nossaifd/) |
| smalldocs | The docs generator of each site, this site too | [docs.smallish.dev](https://docs.smallish.dev/) |

## The pages

| Page | What it tells |
|---|---|
| [System map](system-map.md) | The terms, the job of each package, and the files of a project |
| [Start a fresh folder](fresh-folder.md) | The programs of the machine, the setup for each kind of project, and the first `just check` |
| [Update a project](update.md) | `just install --update`, `--check`, the version floors and the starter files |
| [A commit's path](commit.md) | The steps, the reviews, the pass of jlog, the gate and CI |
| [Releases and versions](releases.md) | The tags that CI makes, the release binaries, `<profile>::version` and the floors |
| [What works and what is proposed](status.md) | Each part of the stack, with its state today |
