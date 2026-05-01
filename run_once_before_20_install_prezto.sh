#!/bin/sh
set -e

# Install Prezto (from offline bundle or git clone)
if [ ! -d "$HOME/.zprezto" ]; then
  OFFLINE_DIR="$HOME/.local/share/offline-packages"

  if [ -f "$OFFLINE_DIR/prezto.tar.gz" ]; then
    echo "Installing Prezto from offline bundle..."
    tar xzf "$OFFLINE_DIR/prezto.tar.gz" -C "$HOME"
  elif command -v git >/dev/null; then
    echo "Installing Prezto from GitHub..."
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "$HOME/.zprezto"
  else
    echo "WARN: Cannot install Prezto (no git, no offline bundle)"
  fi
fi

# Install Prezto Contrib (belak/prezto-contrib)
if [ -d "$HOME/.zprezto" ] && [ ! -d "$HOME/.zprezto/contrib" ]; then
  OFFLINE_DIR="$HOME/.local/share/offline-packages"
  if [ -f "$OFFLINE_DIR/prezto-contrib.tar.gz" ]; then
    echo "Installing Prezto Contrib from offline bundle..."
    tar xzf "$OFFLINE_DIR/prezto-contrib.tar.gz" -C "$HOME/.zprezto"
  elif command -v git >/dev/null; then
    echo "Installing Prezto Contrib from GitHub..."
    git clone https://github.com/belak/prezto-contrib "$HOME/.zprezto/contrib"
  else
    echo "WARN: Cannot install Prezto Contrib (no git, no offline bundle)"
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
  if [ -d "$COMP_DIR" ]; then
    # eza completion (bundled in repo at completions/zsh/_eza)
    SRC="${CHEZMOI_SOURCE_DIR:-$(cd "$(dirname "$0")" && pwd)}/completions/zsh/_eza"
    if [ -f "$SRC" ]; then
      cp "$SRC" "$COMP_DIR/_eza"
      echo "Installed _eza completion into Prezto"
    fi
  fi
fi
