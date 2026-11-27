---
title: A commit's path
---

In a project with the `tasker` role, a commit goes through a gate. The gate is a script of
agent_gest_git_skills that the Git hooks run. It does not run `just check` or the reviews. It reads the
proof that they ran on the same tree, and it stops the commit when the proof is missing. At the
commit-msg hook, it runs one check, `just release-check`, on the message of the commit.

## Deterministic checks, agentic targets and CI

The stack keeps deterministic checks, agentic targets and pull-request CI apart:

- **`just check`** runs only deterministic programs and no AI agent. Every step is a normal tool, and
  `prose-check` runs the Python script `check.py` of nossaifd, not an agent. `just check` runs once on
  your machine before you commit, and `jlog pass` records that pass.
- **Agentic targets** are the separate local recipes `just review`, `just test-review`, `just update-docs`
  and `just prose`. They run only on your machine and never in CI, and the commit gate checks their
  records before a commit by an agent.
- **`just ci`** runs in the pre-push hook and on pull requests in CI. By default it runs only `ci-gate`,
  which checks the `Commit-Gate:` trailer that the commit gate added to each commit. If you leave the list
  `ci` of `.agents/stack.json` empty, tests do not run twice on a pull request. After the pull request
  merges to `main`, a clean CI runner runs the full `just check`.

## The order of the work

1. **Make the change**, and stage it with `git add`.
2. **Run the reviews.** The gate needs them for a commit by an agent, which is a commit with
   `CLAUDECODE`, `CLAUDE_CODE_SESSION_ID` or `CODEX_THREAD_ID` set. Each agentic target prints an `AGENT_TASK v1` packet for a fresh agent:

   | Target | What the fresh agent does | Needed for, in a commit by an agent |
   |---|---|---|
   | `just review` | An adversarial review of the change, on the strongest model | Every commit |
   | `just test-review` | Checks that each new behavior has a test that checks a result | A change of code |
   | `just update-docs` | Writes or changes the docs that the change affects | A change of pages or of the API |
   | `just prose` | Applies the writing guide to the changed pages and docstrings | A change of pages or of the API |

   The agent returns an `AGENT_RESULT v1` packet. The record script accepts it only when
   `jagt result lint` accepts it for the target and the nonce of the task. A record counts when its
   status is `success` and each finding has a test or a reason.
3. **Fix each finding**, and stage the fix. The records must form a chain that ends at the tree of the
   commit, so a fix after a review needs the review again.
4. **Run `just check`.** jlog logs each line and each step. The last line, `jlog pass`, writes a pass
   for the tree.
5. **Commit.** The Git hooks run the gate. The commit-msg hook runs `just release-check` on the message,
   then adds the trailer.

The file `.agents/targets/required.txt` of the parent commit can change which targets a path needs.
`just review` stays required for every commit by an agent. A commit by a person needs only the pass
of `just check`.

## What jlog proves

jlog is the shell of each recipe. It runs each line with the real shell and adds one JSON line to
`.agents/log/just.jsonl`. The first line of a run records the tree of the worktree. `jlog pass` writes a
pass only when all of these are true:

- The command was exactly `just check`.
- Each step of the record has a `step` line. A skip counts only for a step that no profile or role
  provides.
- No line of the run failed.
- The worktree is still the tree of the first line, with no unstaged change and no untracked file.

The [site of jlog](https://rahuldave.com/jlog/) gives each command, the sessions and the
run IDs.

## What the gate checks

The hooks come from the pre-commit framework. `just install` runs `pre-commit install` to put them in
the clone. Since jnterfaces v0.3.0 and agent_gest_git_skills v0.4.0, `tools-check` fails in a clone that
has no hooks, so run `just install` in each new clone. When `CI` is set, `tools-check` does not check the hooks. The gate,
`commit_gate.py`, runs before a commit and before a merge commit. It checks these facts:

- The steps of the record and the required targets exist as recipes.
- The tree of the commit is the tree of the worktree, so each change is staged.
- The run log has a pass of `just check` for that tree.
- For a commit by an agent, the records of the required targets form a chain that ends at that tree.

The commit-msg hook then runs `just release-check` with the message of the commit. A branch keeps the
manifest version of the last tag, and `just release` writes the bump after merge. The hook stops a commit
if profiles disagree or the manifest version is below the last tag. It also stops a commit if
`just release` cannot write the new version into the manifest. It skips this check for a merge, an amend
of a merge, a rebase, or a Justfile with no recipe `release-check`.

After `release-check` passes, the commit-msg hook adds the trailer `Commit-Gate: patch:<patch-id>`, or
`Commit-Gate: tree:<tree>` for a merge. `git commit -n` skips the hooks, so a commit that went around the
gate has no trailer. [The commit gates](https://rahuldave.com/agent_gest_git_skills/specs/commit-gates.html)
tell each rule.

## What CI checks

On a pull request, CI runs `just ci`, and no agent runs in CI. `just ci` runs two parts:

- **`ci-gate`** checks the trailer of each commit of the pull request.
- **The list `ci`** of `.agents/stack.json` names the steps that CI runs again. Each name must be a
  step of `just check`, so CI runs a part of `just check` and never a check that the gate did not see.
  `just install` writes the list into the recipe, so run it after you change the list.

The record has no list `ci` at first, so `just ci` runs only `ci-gate`. The gate already saw a pass of `just check` for each commit. So add a step
only when a clean machine finds what yours cannot, for example a test on Linux. The pre-push hook
runs `just ci` on your machine too. After a merge to `main`, the starter `release.yml` runs the whole
`just check`, then `just release`, as [Releases and versions](releases.md) tells.
