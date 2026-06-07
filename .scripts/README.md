# `.scripts/` — repo automation scripts

Backing implementations for this repo's `mise` tasks: small, deterministic
shell/Python helpers for project setup and the release/changelog workflow.

> **Not to be confused with agentic tools.** These are developer/CI automation
> scripts. The agentic **WAT "tools" layer** lives separately under
> `.agents/tools/` (see [CLAUDE.md](../CLAUDE.md) → *Agentic AI*). Nothing here is
> an agent tool.

Prefer invoking these through their `mise` task (the supported entry point); the
direct paths below are what each task runs and what CI calls.

| Script | `mise` task | Purpose |
|--------|-------------|---------|
| `setup-repo.sh` | `mise run setup-repo -- <name>` | Rename the project off the `barista` placeholder |
| `release.sh` | `mise run release -- {patch\|minor\|major}` | Cut a release end to end |
| `changelog-check.sh` | `mise run changelog-check` | Fail if `[Unreleased]` is empty |
| `changelog-extract.sh` | _(called by CI)_ | Extract a version's notes for the GitHub Release |
| `roll_changelog.py` | _(called by `release.sh`)_ | Promote `[Unreleased]` and rebuild changelog links |

See [.agent/VERSIONING.md](../.agent/VERSIONING.md) for the full versioning and
release policy that these scripts implement.

---

## `setup-repo.sh`

Renames the project from the `barista` placeholder to a new name: rewrites
`src/barista/` and all references.

```bash
mise run setup-repo -- my_project      # supported entry point
.scripts/setup-repo.sh my_project      # equivalent direct call
```

- **Argument:** the new project name. Must be a valid Python package identifier
  (start with a letter or underscore; letters, digits, and underscores only).
- **When to use:** once, right after cloning the template.

## `release.sh`

Cuts a release: runs guards, bumps the version, rolls the changelog, commits,
tags, and pushes. Pushing the tag triggers the release workflow that publishes the
GitHub Release.

```bash
mise run release -- patch     # 0.1.0 -> 0.1.1  (backward-compatible fix)
mise run release -- minor     # 0.1.0 -> 0.2.0  (backward-compatible feature)
mise run release -- major     # 0.1.0 -> 1.0.0  (breaking change)
```

- **Argument:** the SemVer part to bump — `patch`, `minor`, or `major`.
- **Guards (refuses to proceed otherwise):** on `main`, clean working tree, local
  `main` in sync with `origin/main`, a non-empty `[Unreleased]` changelog section,
  and a green `mise run check`.
- **When to use:** to publish a new version. Never hand-edit the version string;
  this is the only supported way to bump it.

## `changelog-check.sh`

Fails if the `[Unreleased]` section of the changelog has no entries, so a release
never ships without notes. Run automatically by `release.sh`.

```bash
mise run changelog-check                  # checks CHANGELOG.md
.scripts/changelog-check.sh path/to.md    # check a specific file
```

- **Argument (optional):** changelog path (default `CHANGELOG.md`).
- **When to use:** manually to sanity-check before releasing; otherwise it runs as
  part of `mise run release`.

## `changelog-extract.sh`

Prints the body of a single version's changelog section (footer link references
stripped), for use as GitHub Release notes. Called by the release workflow.

```bash
.scripts/changelog-extract.sh 0.1.0                  # notes for 0.1.0
.scripts/changelog-extract.sh 0.1.0 path/to.md       # from a specific file
```

- **Arguments:** `<version>` (required), `[changelog-path]` (optional, default
  `CHANGELOG.md`).
- **When to use:** rarely by hand — mainly to preview the notes a release would
  publish. The release workflow calls it automatically.

## `roll_changelog.py`

Promotes `[Unreleased]` to a dated `[X.Y.Z]` section, opens a fresh empty
`[Unreleased]`, and regenerates the GitHub compare/tag link references. Invoked by
`release.sh`; not meant to be run directly.

- **Inputs (environment variables set by `release.sh`):** `NEW_VERSION`,
  `RELEASE_DATE`, `SLUG` (the GitHub `owner/repo`).
- **When to use:** never directly — `mise run release` drives it.
