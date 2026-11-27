# dev.smallish.dev

The site at https://dev.smallish.dev tells how the smallish dev tools fit together. It covers jnterfaces,
the language profiles, the `g*` skills, jlog, gest, jagt, cx, nossaifd and smalldocs. Each tool has
its own site, and this site links to them.

The pages are in `docs/`, and smalldocs builds them with the Atelier theme. The repository uses
jnterfaces with the `tasker`, `prose` and `docs` roles. The workflow `pages.yml` deploys the site to
GitHub Pages after each push to `main`. On pull requests, `check.yml` runs `just ci`. On pushes to
`main`, `release.yml` runs `just check` and `just release`.

| Command | What it does |
|---|---|
| `just install` | Installs the saved stack and its Git hooks in a clone |
| `just docs` | Previews the site |
| `just docs-build` | Builds the site into `docs/_site` |
| `just docs-check` | Checks the site and fails on a broken link |
| `just prose-check` | Checks changed Markdown pages with `check.py` of nossaifd |
| `just check` | Runs every deterministic check of the repository and records a jlog pass |
| `just ci` | Checks the commit-gate trailers on pull requests |
