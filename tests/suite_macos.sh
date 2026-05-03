echo ">>> Running macOS Suite..."
check "Has osxkeychain in .gitconfig" "grep -q 'osxkeychain' \$TMP_HOME/.gitconfig"
check "Brew commands in install script" "grep -q 'brew install' \$TMP_HOME/run_once_before_00_install_packages.sh"
