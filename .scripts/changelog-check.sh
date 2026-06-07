#!/usr/bin/env bash
# Fail if the [Unreleased] section of CHANGELOG.md has no entries.
# A release must always carry human-written notes.
set -euo pipefail

CHANGELOG="${1:-CHANGELOG.md}"

if [[ ! -f "$CHANGELOG" ]]; then
  echo "Error: $CHANGELOG not found." >&2
  exit 1
fi

# Extract the body between the '## [Unreleased]' heading and the next '## ['
# heading, then check whether any non-blank, non-subheading line remains.
body="$(awk '
  /^## \[Unreleased\]/ { in_section = 1; next }
  in_section && /^## \[/ { exit }
  in_section { print }
' "$CHANGELOG")"

# Strip blank lines and category subheadings (e.g. "### Added"); whatever is
# left counts as a real changelog entry.
entries="$(printf '%s\n' "$body" | grep -vE '^[[:space:]]*$' | grep -vE '^### ' || true)"

if [[ -z "$entries" ]]; then
  echo "Error: the [Unreleased] section of $CHANGELOG is empty." >&2
  echo "Add at least one entry under Added/Changed/Fixed/etc. before releasing." >&2
  exit 1
fi

echo "Changelog check passed: [Unreleased] has entries."
