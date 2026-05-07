#!/bin/sh
set -e

# Install Prezto
if [ ! -d "$HOME/.zprezto" ]; then
  if command -v git >/dev/null; then
    echo "Installing Prezto from GitHub..."
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "$HOME/.zprezto"
  else
    echo "WARN: Cannot install Prezto (no git)"
  fi
fi

# Install Prezto Contrib (belak/prezto-contrib)
if [ -d "$HOME/.zprezto" ] && [ ! -d "$HOME/.zprezto/contrib" ]; then
  if command -v git >/dev/null; then
    echo "Installing Prezto Contrib from GitHub..."
    git clone https://github.com/belak/prezto-contrib "$HOME/.zprezto/contrib"
  else
    echo "WARN: Cannot install Prezto Contrib (no git)"
  fi
fi

# Create Prezto symlinks
if [ -d "$HOME/.zprezto" ]; then
  for rcfile in "$HOME"/.zprezto/runcoms/z*; do
    target="$HOME/.$(basename "$rcfile")"
    if [ ! -e "$target" ] && [ "$(basename "$rcfile")" != "zshrc" ] && [ "$(basename "$rcfile")" != "zpreztorc" ]; then
      ln -sf "$rcfile" "$target"
    fi
  done

  # Install extra completions into Prezto
  COMP_DIR="$HOME/.zprezto/modules/completion/external/src"
fi
