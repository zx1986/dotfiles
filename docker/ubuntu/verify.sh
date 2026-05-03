#!/bin/bash
# verify.sh — Run inside Docker to test chezmoi apply + verify result
# Usage:
#   docker exec dotfiles_ubuntu_verify bash ~/xProfile/docker/ubuntu/verify.sh

set -e

echo "============================================"
echo " xProfile Ubuntu Verification"
echo "============================================"
echo ""

SOURCE_DIR="$HOME/xProfile"

# Run chezmoi apply
echo ">>> Running chezmoi init --apply..."
"$HOME/bin/chezmoi" init --apply --source "$SOURCE_DIR" 2>&1

echo ""
echo ">>> Verifying results..."

PASS=0
FAIL=0

check() {
  local desc="$1"
  local result
  result=$(eval "$2" 2>&1) && status="✅" || status="❌ FAIL"
  echo "  $status  $desc"
  [[ "$status" == "✅" ]] && PASS=$((PASS+1)) || FAIL=$((FAIL+1))
}

# Core dotfiles
check ".zshrc deployed"          "[[ -f ~/.zshrc ]]"
check ".zpreztorc deployed"      "[[ -f ~/.zpreztorc ]]"
check ".gitconfig deployed"      "[[ -f ~/.gitconfig ]]"
check "no osxkeychain in gitconfig" "! grep -q osxkeychain ~/.gitconfig"

# Oh My Tmux
check "~/.tmux/ installed"       "[[ -d ~/.tmux/.git ]]"
check "~/.tmux.conf symlink"     "[[ -L ~/.tmux.conf ]]"
check "~/.tmux.conf.local"       "[[ -f ~/.tmux.conf.local ]]"

# Prezto
check "~/.zprezto installed"     "[[ -d ~/.zprezto ]]"
check "Prezto Contrib installed" "[[ -d ~/.zprezto/contrib ]]"
check "_eza completion present"  "[[ -f ~/.zprezto/modules/completion/external/src/_eza ]]"

# Binaries
check "zsh available"            "command -v zsh"
check "tmux available"           "command -v tmux"
check "git available"            "command -v git"
check "fzf available"            "command -v fzf || [[ -f /usr/bin/fzf ]]"
check "fd available"             "command -v fd || command -v fdfind"
check "bat available"            "command -v bat || command -v batcat"

# TPM (inside ~/.tmux/plugins/)
check "TPM installed"            "[[ -f ~/.tmux/plugins/tpm/tpm ]]"

# zshrc renders Linux-specific content (no darwin)
check "zshrc has no darwin leak" "! grep -q 'darwin' ~/.zshrc"
check "zshrc has Linux FZF_BASE" "grep -q FZF_BASE ~/.zshrc || grep -q fzf ~/.zshrc"

echo ""
echo "============================================"
echo " Results: $PASS passed, $FAIL failed"
echo "============================================"

[[ $FAIL -eq 0 ]]
