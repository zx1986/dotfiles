#!/usr/bin/env bats

@test "Zsh starts without errors" {
  run zsh -i -c "exit"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "Spaceship theme is loaded" {
  run zsh -i -c "typeset -f spaceship_prompt > /dev/null && echo 'found'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"found"* ]]
}

@test "Core aliases are available (git, kubectl)" {
  run zsh -i -c "alias g > /dev/null && alias k > /dev/null && echo 'found'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"found"* ]]
}
