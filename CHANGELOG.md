# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
See [.agent/VERSIONING.md](.agent/VERSIONING.md) for the full versioning and
release policy.

## [Unreleased]

### Added

- **Standard procedure** in [CLAUDE.md](CLAUDE.md): the default end-to-end
  implementation workflow (issue → worktree branch → plan → clarify → implement →
  docs → lint/test loop → PR → green CI → ask-before-merge → tidy up → summary)
  that AI agents follow for fixes, features, and chores.
- Versioning and release tooling: `mise run version`, `mise run check`,
  `mise run changelog-check`, and `mise run release -- {patch|minor|major}`,
  backed by `.scripts/release.sh`, `.scripts/changelog-check.sh`, and
  `.scripts/changelog-extract.sh`.
- Tag-triggered GitHub Actions release workflow
  (`.github/workflows/release.yml`) that verifies the tag matches
  `pyproject.toml`, re-runs checks, and publishes a GitHub Release from the
  matching changelog section.
- This `CHANGELOG.md`, following Keep a Changelog.
- [`.scripts/README.md`](.scripts/README.md) documenting each automation script,
  with a quick-index table in [CLAUDE.md](CLAUDE.md).

### Changed

- Renamed the `.tasks/` directory to `.scripts/` (and updated all references) to
  avoid confusion with the agentic WAT "tools" layer in `.agents/tools/`. The
  `mise` task entry points are unchanged.

[Unreleased]: https://github.com/simonsteinberg/barista/commits/main
