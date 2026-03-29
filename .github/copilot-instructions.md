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
- Use type hints for Python code (function signatures, public APIs, and meaningful internal variables where useful).
- Keep typing precise and readable; prefer concrete types and clear Optional/Union usage when needed.

## Testing rules
- Use pytest, not unittest, for new and updated tests.
- Add or update tests in tests/ when changing behavior.
- Keep tests small, readable, and focused on behavior.
- For new functionality, follow Test-Driven Development (TDD):
  - Write failing tests first.
  - Implement the minimal code needed to pass.
  - Refactor while keeping tests green.
- Aim for comprehensive and concise tests that cover expected behavior, edge cases, and regressions without unnecessary duplication.

## Quality checks before commit
- Run lint checks before committing changes.
- Run the relevant tests before committing changes.
- If changing behavior, ensure tests cover the change.
- Do not finish work until linting and all relevant tests pass successfully.

## Practical expectations
- Prefer minimal, targeted edits.
- Do not revert unrelated local changes.
- Keep public APIs stable unless a change is explicitly requested.
