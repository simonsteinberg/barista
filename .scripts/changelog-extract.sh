#!/usr/bin/env bash
# Print the changelog body for a given version, for use as GitHub Release notes.
# Usage: .scripts/changelog-extract.sh <version> [changelog-path]
# Example: .scripts/changelog-extract.sh 0.1.0
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: .scripts/changelog-extract.sh <version> [changelog-path]" >&2
  exit 1
fi

VERSION="$1"
CHANGELOG="${2:-CHANGELOG.md}"

if [[ ! -f "$CHANGELOG" ]]; then
  echo "Error: $CHANGELOG not found." >&2
  exit 1
fi

# Print everything between '## [VERSION]' and the next '## [' heading, dropping
# the footer reference-link lines and trimming leading/trailing blank lines. The
# version is matched literally.
notes="$(awk -v ver="$VERSION" '
  index($0, "## [" ver "]") == 1 { in_section = 1; next }
  in_section && /^## \[/ { exit }
  in_section && /^\[[^]]+\]:[[:space:]]/ { next }
  in_section { print }
' "$CHANGELOG" | sed -e '/./,$!d' | tac | sed -e '/./,$!d' | tac)"

if [[ -z "$notes" ]]; then
  echo "Error: no changelog section found for version $VERSION in $CHANGELOG." >&2
  exit 1
fi

printf '%s\n' "$notes"
