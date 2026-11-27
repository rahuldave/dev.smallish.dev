# Written by just install. Do not edit: the next just install writes it again.
# The recipes of the profiles and roles of this project. .agents/install.just imports this file.

# Each line of a recipe runs through jlog, which adds it to the run log in .agents/log
set shell := ["jlog", "sh", "-cu"]

import? 'roles/agent_gest_git_skills.just'
import? 'roles/nossaifd.just'
import? '../skills/docs/docs.just'

# Check each program that .agents/stack.json records: it is there, and at its version floor
tools-check:
    uv run --no-project --quiet --no-python-downloads --python '>=3.9' python .agents/tools_check.py
    jlog step tools-check

# No profile or role of this repository has fmt-check, so the step logs a skip
fmt-check:
    jlog skip fmt-check "no format checker in this repository"

# No profile or role of this repository has lint, so the step logs a skip
lint:
    jlog skip lint "no linter in this repository"

# No profile or role of this repository has typecheck, so the step logs a skip
typecheck:
    jlog skip typecheck "no type checker in this repository"

# No profile or role of this repository has test, so the step logs a skip
test:
    jlog skip test "no tests in this repository"

# No profile or role of this repository has integration, so the step logs a skip
integration:
    jlog skip integration "no integration tests in this repository"

# No profile or role of this repository has coverage-check, so the step logs a skip
coverage-check:
    jlog skip coverage-check "no coverage check in this repository"

# No profile or role of this repository has docstring-check, so the step logs a skip
docstring-check:
    jlog skip docstring-check "no docstring check in this repository"

# No profile or role of this repository has diff-check, so the step logs a skip
diff-check:
    jlog skip diff-check "no language profile in this repository"

# Warn at once when jlog pass cannot record a pass: the worktree has unstaged changes or untracked files
[private]
worktree-warning:
    @git status --porcelain=v1 -z --untracked-files=all 2>/dev/null | tr '\n\000' '?\n' | awk '$0 == "" { next } skip { skip = 0; next } length($0) < 4 { next } { x = substr($0, 1, 1); y = substr($0, 2, 1) } x ~ /[RC]/ || y ~ /[RC]/ { skip = 1 } y != " " { n++; if (n <= 10) shown = shown (n > 1 ? ", " : "") substr($0, 4) } END { if (n) printf "check: warning: this run cannot record a pass, because the worktree has %d %s: %s%s. The steps still run. Stage or commit the changes to get a pass.\n", n, (n == 1 ? "unstaged change or untracked file" : "unstaged changes or untracked files"), shown, (n > 10 ? ", and more" : "") }' >&2 || true

# Everything a commit must pass: each step, then the pass of jlog for the worktree
check: worktree-warning tools-check release-check ci-gate fmt-check lint typecheck test integration coverage-check docstring-check docs-check prose-check diff-check
    jlog pass

# What CI checks: the trailers of the commit gate, then the steps of the list ci of .agents/stack.json
ci: ci-gate
