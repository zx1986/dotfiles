#!/usr/bin/env bats

@test "Zsh starts without errors" {
  run zsh -i -c "exit"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "Spaceship theme is loaded" {
  run zsh -i -c "typeset -f spaceship_prompt > /dev/null && ([[ -n \$SPACESHIP_VERSION ]] || [[ -n \$SPACESHIP_ROOT ]]) && echo 'found'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"found"* ]]
}

@test "Core aliases are available and mapped correctly (g, k)" {
  run zsh -i -c "[[ \"\$(alias g)\" == \"g=git\" ]] && [[ \"\$(alias k)\" == \"k=kubectl\" ]] && echo 'found'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"found"* ]]
}

@test "Zsh completions are available (git, kubectl)" {
  run zsh -i -c "[[ \"\$(whence -w _git)\" == \"_git: function\" ]] && [[ \"\$(whence -w _kubectl)\" == \"_kubectl: function\" ]] && echo 'found'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"found"* ]]
}

@test "Right prompt (RPROMPT) is empty" {
  run zsh -i -c "echo \"\$RPROMPT\""
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "git config has correct user email" {
  run git config --get user.email
  [ "$status" -eq 0 ]
  [ "$output" = "zx1986@gmail.com" ]
}

@test "ssh key id_ed25519 exists" {
  [ -f "$HOME/.ssh/id_ed25519" ]
}

@test "ssh key id_ed25519 has correct permissions" {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    run stat -c "%a" "$HOME/.ssh/id_ed25519"
    [ "$output" = "600" ]
  fi
}

@test "antigravity-cli is available" {
  run zsh -i -c "command -v agy"
  [ "$status" -eq 0 ]
}

@test "neovim is installed and version is 0.9+" {
  run nvim --version
  [ "$status" -eq 0 ]
  # Check for 0.9 or 0.10 or 0.11 etc.
  [[ "$output" =~ "NVIM v0."([9]|[1-9][0-9]) ]]
}

@test "tree is available" {
  run command -v tree
  [ "$status" -eq 0 ]
}

@test "ag is available" {
  run command -v ag
  [ "$status" -eq 0 ]
}

@test "tmux is available" {
  run command -v tmux
  [ "$status" -eq 0 ]
}

@test "tmux plugins are installed" {
  # Check for at least one default plugin from dot_tmux.conf.local
  [ -d "$HOME/.tmux/plugins/tmux-sensible" ]
}

@test "fzf keybindings are loaded" {
  run zsh -i -c "typeset -f fzf-history-widget > /dev/null && echo 'found'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"found"* ]]
}

@test "delta is available and version is 0.18+" {
  run delta --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ "delta 0."(1[8-9]|[2-9][0-9]) ]]
}

@test "gh CLI is available" {
  run command -v gh
  [ "$status" -eq 0 ]
}

