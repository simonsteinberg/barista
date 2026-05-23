#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: .tasks/setup-repo.sh <new-project-name>"
  echo "Example: .tasks/setup-repo.sh myproject"
  exit 1
fi

NEW_NAME="$1"

# Validate the new name (alphanumeric and underscore only)
if ! [[ "$NEW_NAME" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
  echo "Error: Project name must start with a letter or underscore, and contain only alphanumeric characters and underscores."
  exit 1
fi

if [[ ! -d "src" ]]; then
  echo "Error: src/ directory not found. Cannot infer current project name."
  exit 1
fi

CURRENT_NAME="$(find src -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | head -n 1)"
if [[ -z "$CURRENT_NAME" ]]; then
  echo "Error: No project directories found under src/. Cannot infer current project name."
  exit 1
fi

echo "Renaming project from '$CURRENT_NAME' to '$NEW_NAME'..."

# Rename directory if it exists
if [[ "$CURRENT_NAME" != "$NEW_NAME" && -d "src/${CURRENT_NAME}" ]]; then
  mv "src/${CURRENT_NAME}" "src/${NEW_NAME}"
  echo "✓ Renamed src/${CURRENT_NAME} → src/${NEW_NAME}"
fi

# Build legacy name variants (case variations + double-letter typos)
declare -A LEGACY_NAMES=()
add_legacy_name() {
  local name="$1"
  if [[ -n "$name" ]]; then
    LEGACY_NAMES["$name"]=1
  fi
}

add_legacy_name "$CURRENT_NAME"
add_legacy_name "${CURRENT_NAME,,}"
add_legacy_name "${CURRENT_NAME^^}"
add_legacy_name "${CURRENT_NAME^}"

for ((i=0; i<${#CURRENT_NAME}; i++)); do
  ch="${CURRENT_NAME:$i:1}"
  variant="${CURRENT_NAME:0:$((i+1))}${ch}${CURRENT_NAME:$((i+1))}"
  add_legacy_name "$variant"
done

existing_variants=("${!LEGACY_NAMES[@]}")
for variant in "${existing_variants[@]}"; do
  add_legacy_name "${variant,,}"
  add_legacy_name "${variant^^}"
  add_legacy_name "${variant^}"
done

legacy_list=($(printf '%s\n' "${!LEGACY_NAMES[@]}" | sort))
perl_args=()
for legacy in "${legacy_list[@]}"; do
  if [[ "$legacy" != "$NEW_NAME" ]]; then
    perl_args+=("-e" "s/\\Q${legacy}\\E/${NEW_NAME}/g")
  fi
done

# Find and replace in files (excluding git, venv, cache directories, and binary files)
if [[ ${#perl_args[@]} -gt 0 ]]; then
  find . \
    -not -path './.git/*' \
    -not -path './.venv/*' \
    -not -path '*/__pycache__/*' \
    -not -path '*/.pytest_cache/*' \
    -not -path '*/node_modules/*' \
    -not -path '*/htmlcov/*' \
    -type f \
    ! -name '*.pyc' \
    ! -name '*.so' \
    ! -name '*.o' \
    -exec perl -pi "${perl_args[@]}" {} +
fi

echo "✓ Replaced all occurrences of legacy names with '$NEW_NAME'"
echo "Setup complete!"
