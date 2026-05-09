#!/bin/zsh
# This script simulates sourcing the relevant part of .zshrc in a fresh zsh process
# to verify that 'local' doesn't cause errors.

ZSHRC_PATH="$1"
if [[ ! -f "$ZSHRC_PATH" ]]; then
  echo "Error: .zshrc not found at $ZSHRC_PATH"
  exit 1
fi

# Extract the fzf block and some context
# We'll use a subshell to avoid polluting the current shell
# and to capture any stderr from 'local' usage at global scope.
ERROR_OUTPUT=$(zsh -c "source $ZSHRC_PATH" 2>&1)
EXIT_CODE=$?

if [[ $EXIT_CODE -ne 0 ]]; then
  echo "FAILED: .zshrc sourcing failed with exit code $EXIT_CODE"
  echo "Error output:"
  echo "$ERROR_OUTPUT"
  exit 1
fi

if echo "$ERROR_OUTPUT" | grep -q "local: can only be used in a function"; then
  echo "FAILED: .zshrc contains 'local' at global scope"
  echo "$ERROR_OUTPUT"
  exit 1
fi

echo "PASSED: .zshrc sourced successfully without global 'local' errors"
