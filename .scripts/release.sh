#!/usr/bin/env bash
# Cut a release: bump the version, roll the changelog, commit, tag, and push.
# Usage: .scripts/release.sh {patch|minor|major}
#   (invoke via: mise run release -- patch)
#
# See .agent/VERSIONING.md for the full policy. This script never cuts a release
# from a dirty tree, an out-of-date main, or an empty [Unreleased] changelog.
set -euo pipefail

PART="${1:-}"
case "$PART" in
  patch | minor | major) ;;
  *)
    echo "Usage: mise run release -- {patch|minor|major}" >&2
    exit 1
    ;;
esac

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# --- Guards ----------------------------------------------------------------
branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$branch" != "main" ]]; then
  echo "Error: releases must be cut from 'main' (currently on '$branch')." >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Error: working tree is not clean. Commit or stash changes first." >&2
  exit 1
fi

git fetch --quiet origin main
local_sha="$(git rev-parse main)"
remote_sha="$(git rev-parse origin/main)"
if [[ "$local_sha" != "$remote_sha" ]]; then
  echo "Error: local 'main' is not in sync with 'origin/main'." >&2
  echo "  local:  $local_sha" >&2
  echo "  origin: $remote_sha" >&2
  exit 1
fi

# --- Changelog must carry notes -------------------------------------------
.scripts/changelog-check.sh

# --- Never release from a red tree ----------------------------------------
mise run check

# --- Bump the version ------------------------------------------------------
uv version --bump "$PART"
NEW_VERSION="$(uv version --short)"
TAG="v${NEW_VERSION}"
echo "Releasing ${TAG}"

if git rev-parse -q --verify "refs/tags/${TAG}" >/dev/null; then
  echo "Error: tag ${TAG} already exists." >&2
  exit 1
fi

# --- Roll the changelog ----------------------------------------------------
RELEASE_DATE="$(date -u +%Y-%m-%d)"
SLUG="$(git remote get-url origin \
  | sed -E 's#^git@[^:]+:#https://github.com/#; s#^https?://[^/]+/##; s#\.git$##')"

NEW_VERSION="$NEW_VERSION" RELEASE_DATE="$RELEASE_DATE" SLUG="$SLUG" \
  uv run python .scripts/roll_changelog.py

# --- Commit, tag, push -----------------------------------------------------
git add pyproject.toml uv.lock CHANGELOG.md
git commit -m "chore(release): ${TAG}"
git tag -a "$TAG" -m "$TAG"
git push --follow-tags

echo "Pushed ${TAG}. The release workflow will publish the GitHub Release."
