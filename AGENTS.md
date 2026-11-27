<!-- begin lines of tasker, the tasker role, from agent_gest_git_skills at 7aa9ba9. -->
<!-- Last written to AGENTS.md by `install_stack.py --update tasker prose docs --target . --defaults --answer docs-publish=no`. The record is parts."AGENTS.md" in .agents/stack.json. -->
Read and follow @.agents/instructions/tasker.md
<!-- end lines of tasker. `just uninstall tasker` removes them. -->
<!-- begin lines of prose, the prose role, from nossaifd at b127b35. -->
<!-- Last written to AGENTS.md by `install_stack.py --update tasker prose docs --target . --defaults --answer docs-publish=no`. The record is parts."AGENTS.md" in .agents/stack.json. -->
Read and follow @.agents/instructions/prose.md
<!-- end lines of prose. `just uninstall prose` removes them. -->

# Agent Instructions

## Project Context

- Project name: `dev.smallish.dev`
- Main source directory: `docs/` (docs-only smalldocs site with no language profile)
- Primary docs/specs: `docs/`, `docs/_smalldocs.yml`, `README.md`
- Detailed workflow playbook: `.agents/skills/gtw/references/gest_codex_workflow.md`

## Repository Policy

- Default branch: `main`. Individual documentation changes go on topic branches and merge to `main` via pull requests.
- Roles installed via jnterfaces: `tasker` (`git` variant, `issues=top`, `review-model=strongest`), `prose` (nossaifd), and `docs` (`docs-publish=no`).
- CI workflows:
  - `.github/workflows/check.yml` runs `just ci` on pull requests.
  - `.github/workflows/release.yml` runs `just check` and `just release` on pushes to `main`.
  - `.github/workflows/pages.yml` builds `docs/_site` via `just docs-build` and deploys to GitHub Pages on pushes to `main` (GitHub Pages is configured to deploy from GitHub Actions, not `gh-pages`).

## Command Contract

- Install or update the jnterfaces stack: `just install` / `just install --update` / `just install --check`
- Full deterministic local check: `just check`
- Pull-request CI check: `just ci`
- Preview the site locally: `just docs`
- Build the site into `docs/_site`: `just docs-build`
- Check site links and config: `just docs-check`
- Run the deterministic prose checker on changed Markdown files: `just prose-check`
- Agentic commit-gate targets: `just review`, `just update-docs`, `just prose`
