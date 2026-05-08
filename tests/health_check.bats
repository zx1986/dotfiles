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
