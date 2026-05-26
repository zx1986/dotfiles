echo ">>> Running Linux Suite..."
check "No osxkeychain in .gitconfig" "! grep -q 'osxkeychain' \$TMP_HOME/.gitconfig"
check "APT commands in install script" "grep -q 'apt-get install' \$TMP_HOME/00_install_packages.sh"
check "Font installation script rendered" "grep -q 'JetBrainsMono' \$TMP_HOME/after_install_fonts.sh"
