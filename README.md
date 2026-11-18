# dev.smallish.dev

The site at https://dev.smallish.dev tells how the smallish dev tools fit together. It covers jnterfaces,
the language profiles, the `g*` skills, jlog, gest, jagt, cx, nossaifd and smalldocs. Each tool has
its own site, and this site links to them.

The pages are in `docs/`, and smalldocs builds them with the Atelier theme. The workflow `pages.yml`
deploys the site to GitHub Pages after each push to `main`.

| Command | What it does |
|---|---|
| `just docs` | Previews the site |
| `just docs-build` | Builds the site into `docs/_site` |
| `just docs-check` | Builds the site in a temporary folder, and fails on a broken link |
| `just prose-check` | Checks each Markdown page with `check.py` of nossaifd |
| `just check` | Runs `docs-check` and `prose-check`. CI runs it and no other check. |

`prose-check` reads `~/Projects/nossaifd/check.py`, or the path in `NOSSAIFD_CHECK`.
