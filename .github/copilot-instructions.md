# Barista Agent Instructions

## Project layout
- Python package source lives under src/barista.
- Tests live under tests.
- Main project metadata and tool config are in pyproject.toml and mise.toml.

## Python and tooling
- Use Python 3.12 for local commands.
- Use mise tasks where possible.
- Useful tasks:
  - mise run test
  - mise run lint

## Testing rules
- Use pytest, not unittest, for new and updated tests.
- Add or update tests in tests/ when changing behavior.
- Keep tests small, readable, and focused on behavior.

## Quality checks before commit
- Run lint checks before committing changes.
- Run the relevant tests before committing changes.
- If changing behavior, ensure tests cover the change.

## Practical expectations
- Prefer minimal, targeted edits.
- Do not revert unrelated local changes.
- Keep public APIs stable unless a change is explicitly requested.
