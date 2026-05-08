echo ">>> Running macOS Suite..."
check "Has osxkeychain in .gitconfig" "grep -q 'osxkeychain' \$TMP_HOME/.gitconfig"
check "Brew commands in install script" "grep -q 'brew install' \$TMP_HOME/00_install_packages.sh"
check "fzf in brew install list" "grep -q 'brew install.*fzf' \$TMP_HOME/00_install_packages.sh"
