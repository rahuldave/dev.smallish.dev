---
title: Bring an existing project in
---

A repository that already has code, a `Justfile`, `AGENTS.md` or CI workflows needs different steps than
an empty folder. The installer keeps your files and merges only its own blocks. Keep the custom recipes
and workflows that you still need, and let the stack replace the rest.

This page covers the migration steps, CI workflows and `.gitignore`. For low-level block and clash rules,
see [Bring an existing project in](https://rahuldave.com/jnterfaces/existing-project.html) on the
jnterfaces site. First install the machine programs and clone `jnterfaces` as shown in
[Start a new project](fresh-folder.md#set-up-your-machine-once).

## Start with a dry run

In the repository root, preview the install with `--dry-run` and `--update`. `--dry-run` checks version
floors and prints every file that the installer would write or change. It makes no edits to the
repository. `--update` pulls the latest release tags in your local package clones first.

For a language repository, pass `--profile python`, `--profile typescript` or `--profile rust`. For a
docs-only repository (like this site), name the roles directly:

```bash
uv run "${SKILL_PACKAGES_DIR:-$HOME/.local/share/skill-packages}/jnterfaces/scripts/install_stack.py" \
  --dry-run --update tasker prose docs --target . --defaults --answer docs-publish=no
```

When an AI agent runs the installer with no terminal, pass `--defaults` plus any `--answer KEY=VALUE`
overrides. Without them, the installer prints the setup questions (`issues`, `integration`, `tasker`,
`review-model`, `docs-publish`) and exits with no changes.

## Resolve `Justfile` recipe clashes

`install_stack.py` keeps your `Justfile` and inserts a short import block at the top
(`import? '.agents/install.just'` and `JLOG_RUN`). But some recipe names belong to the installer or to an
active role, so your `Justfile` cannot define them:

- **Installer names.** `install`, `uninstall`, `env-lab` and the variable `jn_copier`.
- **Profiles and roles.** `python`, `typescript`, `rust`, and role recipes such as `review`, `ci-gate`,
  `prose-check`, `docs`, `docs-build`, `docs-check` and `docs-publish`.

Before you run the real install, decide whether to replace or keep your `Justfile`:

- **Hand the recipes over to jnterfaces.** If your old `Justfile` only defined role recipes by hand (such
  as `docs`, `docs-check`, `prose-check` and `check`), delete it first. The installer then writes a
  starter `Justfile`, and every role recipe and `just check` work with no clashes.
- **Keep custom project recipes.** Rename any recipe that clashes (for example rename `install` to
  `setup`). You may keep custom overrides for steps such as `lint`, `test` or `check`. End each step with
  `jlog step NAME` (with no `#!` shebang line). A custom `check` must start with `worktree-warning`, run
  every step listed in `.agents/stack.json`, and end with `jlog pass`.

## Run the installer

Once you clear any recipe clash, drop `--dry-run` and run the same command:

```bash
uv run "${SKILL_PACKAGES_DIR:-$HOME/.local/share/skill-packages}/jnterfaces/scripts/install_stack.py" \
  --update tasker prose docs --target . --defaults --answer docs-publish=no
```

That command clones any missing packages (`agent_gest_git_skills`, `nossaifd` or profiles) into your
package cache. It writes `.agents/`, `.claude/`, `.codex/` and `.pre-commit-config.yaml`, installs
`pre-commit` if needed, and registers the Git hooks in `.git/hooks/`.

## Audit CI workflows and GitHub Pages

`install_stack.py` writes a starter file only when the project has none. Inspect every file in
`.github/workflows/` right after install:

- **Old `check.yml`.** If the repository already had its own `check.yml`, the installer skipped it.
  Delete the old file before install (or copy the `tasker` starter by hand) so pull requests run
  `just ci`.
- **Other workflows that call `just`.** Every recipe line now runs through `jlog`. Any workflow that
  calls `just` (such as a `pages.yml` that runs `just docs-build`) fails in CI until it installs `jlog`.
- **GitHub Pages through Actions (`pages.yml`).** If GitHub Pages deploys through GitHub Actions rather
  than `gh-pages`, pass `--answer docs-publish=no`. Keep `.github/workflows/docs-publish.yml` so future
  `just install` runs do not recreate it. Remove its `push` trigger (leave only `workflow_dispatch`) and
  set its permissions to `contents: read`.
- **Programs that `tools-check` verifies in `release.yml`.** In CI, `tools-check` skips only per-clone
  checks (`commit-hooks`), not binary version floors. A CI job that runs `just check` with `tasker` needs
  `just`, `uv`, `jlog`, `gest` and `jagt` on `PATH`. Because the `tasker` starter `release.yml` omits
  `gest` and `jagt`, add pinned installs for both. With `docs` on, `docs-check` runs `smalldocs` through
  `uvx`, and you can also preinstall the pinned `smalldocs` wheel in CI.

## Check `.gitignore` and `AGENTS.md`

- **Ignore Python bytecode in non-Python repositories.** Helper scripts under `.agents/skills/` run with
  Python and can leave untracked `__pycache__/` folders behind. If your repository has no Python profile,
  add `__pycache__/` and `*.py[cod]` to `.gitignore` so stray bytecode does not block `jlog pass` or the
  commit gate.
- **Fill in `AGENTS.md`.** If the installer wrote a starter `AGENTS.md`, replace each `<replace-me>`
  placeholder with your project name, folders, default branch, CI workflows and commands. If you kept
  custom recipe names in your `Justfile`, map each task to your recipe name in `AGENTS.md` so agents
  follow the `just` skill.

## Verify with the skills and make the first commit

The commit gate checks the whole worktree, both staged files and any unstaged or untracked files. Follow
this order for the first commit:

1. Stage everything and run the deterministic checks:

   ```bash
   git add --all
   just install --check
   just check
   ```

   If a step fails, fix it and stage the fix, then run `just check` again. If you have a docs site, run
   `just docs-build` as well to check strict site output.
2. Run targets that edit files first (`just update-docs`, then `just prose`). In Claude Code or Codex
   with `tasker` on, an agent commit needs commit-gate records from both targets. On the first commit,
   new Markdown files under `.agents/` and `AGENTS.md` trigger them even if `docs/` did not change.
   Manual `nossaifd` steps do not write the `prose` record. Without `tasker`, run `just prose-check -v`
   and the `nossaifd` and `declaude` steps directly.
3. Run the review targets last (`just review`, and `just test-review` if code changed). Hand each printed
   `AGENT_TASK` packet to a fresh subagent. In a repository with old files, an adversarial review catches
   workflow gaps, stale README instructions and overly broad permissions before push.
4. If a review finds defects, fix them, stage the fixes and re-run any target whose input files changed.
   Then run `just check` one final time and commit. The `pre-commit` and `commit-msg` hooks verify
   `jlog pass` on the staged tree and stamp the `Commit-Gate:` trailer. In Claude Code and Codex, hooks
   record `AGENT_RESULT` packets automatically. In a plain terminal or another harness, the gate checks
   `jlog pass`, while fresh review and prose subagents still catch defects before push.

When you push, the `pre-push` hook runs `just ci` locally. If your repository uses SSH remotes and your
clone points to HTTPS, switch `origin` to SSH (or configure `gh auth setup-git`) before you push workflow
changes.
