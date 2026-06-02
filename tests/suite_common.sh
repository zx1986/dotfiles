echo ">>> Running Common Suite..."
check ".gitconfig rendered" "[[ -f \$TMP_HOME/.gitconfig ]]"
check ".gitmessage rendered" "[[ -f \$TMP_HOME/.gitmessage ]]"
check ".zshrc rendered" "[[ -f \$TMP_HOME/.zshrc ]]"
check ".zshrc contains fzf_shell_paths" "grep -q 'fzf_shell_paths' \$TMP_HOME/.zshrc"
# Add some checks for directories we expect to exist
check ".tmux.conf.local exists" "[[ -f \$TMP_HOME/.tmux.conf.local ]]"
check "antigravity installation script rendered" "[[ -f \$TMP_HOME/06_install_antigravity.sh ]]"
check "tmux plugin installation script rendered" "[[ -f \$TMP_HOME/after_30_install_tmux_plugins.sh ]]"
