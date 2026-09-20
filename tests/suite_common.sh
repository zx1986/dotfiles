echo ">>> Running Common Suite..."
check ".gitconfig rendered" "[[ -f \$TMP_HOME/.gitconfig ]]"
check ".gitmessage rendered" "[[ -f \$TMP_HOME/.gitmessage ]]"
check ".zshrc rendered" "[[ -f \$TMP_HOME/.zshrc ]]"
check ".zshrc contains fzf_shell_paths" "grep -q 'fzf_shell_paths' \$TMP_HOME/.zshrc"
# Add some checks for directories we expect to exist
check ".tmux.conf.local exists" "[[ -f \$TMP_HOME/.tmux.conf.local ]]"
check "antigravity installation script rendered" "[[ -f \$TMP_HOME/06_install_antigravity.sh ]]"
check "antigravity installation script installs mattpocock/skills" "grep -q 'mattpocock/skills' \$TMP_HOME/06_install_antigravity.sh"
check "ai_tools installation script rendered" "[[ -f \$TMP_HOME/07_install_ai_tools.sh ]]"
if [[ "$OS_TYPE" == "darwin" ]]; then
  check "ai_tools script installs codegraph" "grep -q '@colbymchenry/codegraph' \$TMP_HOME/07_install_ai_tools.sh"
  check "ai_tools script installs neovim npm" "grep -q 'neovim' \$TMP_HOME/07_install_ai_tools.sh"
  check "ai_tools script installs archify" "grep -q 'tt-a1i/archify' \$TMP_HOME/07_install_ai_tools.sh"
else
  check "ai_tools script renders Linux placeholder" "grep -q 'Linux support not yet implemented' \$TMP_HOME/07_install_ai_tools.sh"
fi

