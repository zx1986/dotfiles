echo ">>> Running Common Suite..."
check ".gitconfig rendered" "[[ -f \$TMP_HOME/.gitconfig ]]"
check ".gitmessage rendered" "[[ -f \$TMP_HOME/.gitmessage ]]"
check ".zshrc rendered" "[[ -f \$TMP_HOME/.zshrc ]]"
# Add some checks for directories we expect to exist
check ".tmux.conf.local exists" "[[ -f \$TMP_HOME/.tmux.conf.local ]]"
