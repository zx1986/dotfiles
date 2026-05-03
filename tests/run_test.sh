#!/bin/bash
set -e

OS_TYPE=$1 # "linux" or "darwin"
if [[ -z "$OS_TYPE" ]]; then
  echo "Usage: $0 <linux|darwin>"
  exit 1
fi

TMP_HOME=$(mktemp -d -t xprofile-test-XXXXXX)
trap 'rm -rf "$TMP_HOME"' EXIT

echo ">>> Simulating $OS_TYPE environment in $TMP_HOME..."

# Identify templates and regular files
find . -maxdepth 1 \( -name "dot_*" -o -name "run_once_*" \) -print0 | while IFS= read -r -d '' f; do
  f="${f#./}"
  if [[ "$f" == dot_* ]]; then
    TARGET_NAME=".${f#dot_}"
  else
    TARGET_NAME="$f"
  fi
  TARGET_NAME="${TARGET_NAME%.tmpl}"
  
  if [[ "$f" == *.tmpl ]]; then
    # Render template with mocked OS and homeDir
    chezmoi execute-template -f --init --source=. --override-data "{\"chezmoi\": {\"os\": \"$OS_TYPE\", \"homeDir\": \"$TMP_HOME\"}}" "$f" > "$TMP_HOME/$TARGET_NAME"
  else
    # Copy regular file
    cp -r "$f" "$TMP_HOME/$TARGET_NAME"
  fi
done

# Export TMP_HOME for suites
export TMP_HOME

# Load assertions
source "$(dirname "$0")/lib_assert.sh"

# Run suites
# Note: These files will be created in Task 2. For now, just source them if they exist.
if [[ -f "$(dirname "$0")/suite_common.sh" ]]; then
  source "$(dirname "$0")/suite_common.sh"
fi

if [[ "$OS_TYPE" == "linux" ]] && [[ -f "$(dirname "$0")/suite_linux.sh" ]]; then
  source "$(dirname "$0")/suite_linux.sh"
elif [[ "$OS_TYPE" == "darwin" ]] && [[ -f "$(dirname "$0")/suite_macos.sh" ]]; then
  source "$(dirname "$0")/suite_macos.sh"
fi

report_results
