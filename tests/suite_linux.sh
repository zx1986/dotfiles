echo ">>> Running Linux Suite..."
check "No osxkeychain in .gitconfig" "! grep -q 'osxkeychain' \$TMP_HOME/.gitconfig"
check "APT commands in install script" "grep -q 'apt-get install' \$TMP_HOME/run_once_before_00_install_packages.sh"
