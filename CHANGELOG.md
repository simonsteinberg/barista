# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
See [.agent/VERSIONING.md](.agent/VERSIONING.md) for the full versioning and
release policy.

## [Unreleased]

### Added

- Versioning and release tooling: `mise run version`, `mise run check`,
  `mise run changelog-check`, and `mise run release -- {patch|minor|major}`,
  backed by `.tasks/release.sh`, `.tasks/changelog-check.sh`, and
  `.tasks/changelog-extract.sh`.
- Tag-triggered GitHub Actions release workflow
  (`.github/workflows/release.yml`) that verifies the tag matches
  `pyproject.toml`, re-runs checks, and publishes a GitHub Release from the
  matching changelog section.
- This `CHANGELOG.md`, following Keep a Changelog.

[Unreleased]: https://github.com/simonsteinberg/barista/commits/main
