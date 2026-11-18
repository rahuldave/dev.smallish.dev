# The recipes of the site. CI runs just check, in .github/workflows/check.yml, and no other check.
smalldocs := "uvx --quiet smalldocs@0.5.12"
# The checker of nossaifd. CI sets NOSSAIFD_CHECK to its clone of nossaifd.
nossaifd_check := env("NOSSAIFD_CHECK", home_directory() / "Projects/nossaifd/check.py")

# Every check of the repository, in this order
check: docs-check prose-check

# Build the site in a temporary folder, and fail on a broken link or on Markdown that smalldocs does not read
docs-check:
  {{smalldocs}} check docs

# The checker of nossaifd on each Markdown page of the repository. A hard note fails it
prose-check:
  git ls-files -z '*.md' | xargs -0 uv run --no-project --quiet python {{quote(nossaifd_check)}}

# Preview the site, and build it again on each change
docs:
  {{smalldocs}} preview docs

# Build the site into docs/_site, in strict mode
docs-build:
  {{smalldocs}} render docs --strict
