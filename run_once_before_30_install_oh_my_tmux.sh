#!/bin/sh
set -e

# Install Oh My Tmux (gpakosz/.tmux)
if [ ! -d "$HOME/.tmux" ]; then
  OFFLINE_DIR="$HOME/.local/share/offline-packages"

  if [ -f "$OFFLINE_DIR/oh-my-tmux.tar.gz" ]; then
    echo "Installing Oh My Tmux from offline bundle..."
    tar xzf "$OFFLINE_DIR/oh-my-tmux.tar.gz" -C "$HOME"
    # Tarball extracts to "oh-my-tmux", rename to ".tmux"
    mv "$HOME/oh-my-tmux" "$HOME/.tmux"
  elif command -v git >/dev/null; then
    echo "Installing Oh My Tmux from GitHub..."
    git clone --depth=1 https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
  else
    echo "WARN: Cannot install Oh My Tmux (no git, no offline bundle)"
  fi
fi

# Install TPM (Tmux Plugin Manager) into ~/.tmux/plugins/tpm
if [ ! -f "$HOME/.tmux/plugins/tpm/tpm" ]; then
  OFFLINE_DIR="$HOME/.local/share/offline-packages"
  mkdir -p "$HOME/.tmux/plugins"

  if [ -f "$OFFLINE_DIR/tpm.tar.gz" ]; then
    echo "Installing TPM from offline bundle..."
    tar xzf "$OFFLINE_DIR/tpm.tar.gz" -C "$HOME/.tmux/plugins/"
  elif command -v git >/dev/null; then
    echo "Installing TPM from GitHub..."
    git clone --depth 1 https://github.com/tmux-plugins/tpm.git "$HOME/.tmux/plugins/tpm"
  else
    echo "WARN: Cannot install TPM (no git, no offline bundle)"
  fi
fi
