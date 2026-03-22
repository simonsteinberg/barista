# barista

Minimal Python project managed with mise and uv.

## Quickstart

1. Install tools and project dependencies:
```bash
mise install
mise run sync
```

2. Enable pre-commit hooks:
```bash
uv run pre-commit install
```

3. Run the greeting CLI:
```bash
uv run barista-greet
```

Expected output:

	Hello barista (version <CURRENT_VERSION>)

## Quality checks

- Pre-commit runs lint and test before each commit.
- CI runs lint and test on pull requests and on pushes to `main`.
