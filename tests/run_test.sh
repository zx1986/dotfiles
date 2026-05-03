#!/bin/bash
set -e

OS_TYPE=$1 # "linux" or "darwin"
if [[ -z "$OS_TYPE" ]]; then
  echo "Usage: $0 <linux|darwin>"
  exit 1
fi

TMP_HOME=$(mktemp -d -t xprofile-test-XXXXXX)
# Isolate cache and state for safety, though apply --dry-run or --destination might be enough, 
# full isolation is better.
TMP_CACHE=$(mktemp -d -t chezmoi-cache-XXXXXX)
TMP_STATE=$(mktemp -t chezmoi-state-XXXXXX)

trap 'rm -rf "$TMP_HOME" "$TMP_CACHE" "$TMP_STATE"' EXIT

echo ">>> Simulating $OS_TYPE environment in $TMP_HOME..."

# 1. Render all dotfiles (exclude scripts to avoid execution)
# We use --override-data to mock the .chezmoi.os variable
chezmoi apply \
  --cache "$TMP_CACHE" \
  --persistent-state "$TMP_STATE" \
  --destination "$TMP_HOME" \
  --source . \
  --force \
  --exclude scripts \
  --override-data "{\"chezmoi\": {\"os\": \"$OS_TYPE\"}}"

# 2. Render scripts manually using execute-template (safe, no execution)
# We find all run_once_ or run_always_ scripts in the source dir
find . -maxdepth 1 -name "run_*" | while read -r f; do
  f="${f#./}"
  # Map source name to target name (usually just removing run_... prefix and .tmpl)
  # For our project, we have run_once_before_00_install_packages.sh.tmpl -> 00_install_packages.sh
  TARGET_NAME=$(echo "$f" | sed 's/^run_once_before_//' | sed 's/^run_once_//' | sed 's/^run_always_//' | sed 's/\.tmpl$//')
  
  chezmoi execute-template \
    -f \
    --init \
    --source . \
    --override-data "{\"chezmoi\": {\"os\": \"$OS_TYPE\", \"homeDir\": \"$TMP_HOME\"}}" \
    "$f" > "$TMP_HOME/$TARGET_NAME"
done

# Export TMP_HOME for suites
export TMP_HOME

# Load assertions
source "$(dirname "$0")/lib_assert.sh"

# Run suites
if [[ -f "$(dirname "$0")/suite_common.sh" ]]; then
  source "$(dirname "$0")/suite_common.sh"
fi

if [[ "$OS_TYPE" == "linux" ]] && [[ -f "$(dirname "$0")/suite_linux.sh" ]]; then
  source "$(dirname "$0")/suite_linux.sh"
elif [[ "$OS_TYPE" == "darwin" ]] && [[ -f "$(dirname "$0")/suite_macos.sh" ]]; then
  source "$(dirname "$0")/suite_macos.sh"
fi

report_results
