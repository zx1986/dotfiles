# Robust fzf Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ensure `fzf` keybindings and completion work on all systems by adding a self-healing download mechanism to the Zsh configuration.

**Architecture:** Update the Zsh post-setup template to detect missing integration files and automatically download them from GitHub to `~/.config/fzf/`. Add a health check to verify the integration.

**Tech Stack:** zsh, chezmoi, curl, BATS (testing)

---

### Task 1: Update Zsh Post-Setup Template

**Files:**
- Modify: `.chezmoitemplates/zsh_post_setup`

- [ ] **Step 1: Replace current fzf block with self-healing logic**

Replace the entire `# fzf` block in `.chezmoitemplates/zsh_post_setup`.

```zsh
# fzf
if command -v fzf >/dev/null; then
  # Dynamic detection for brew/apt installs
  () {
    local fzf_shell_paths=(
      "/opt/homebrew/opt/fzf/shell"      # Homebrew (Apple Silicon)
      "/usr/local/opt/fzf/shell"         # Homebrew (Intel)
      "/usr/share/doc/fzf/examples"      # Ubuntu/Debian
      "$HOME/.config/fzf"                # Local cache
    )

    local found=false
    for base in $fzf_shell_paths; do
      if [ -f "$base/key-bindings.zsh" ]; then
        [ -f "$base/completion.zsh" ] && source "$base/completion.zsh"
        source "$base/key-bindings.zsh"
        found=true; break
      fi
    done

    # Self-heal: Download if missing
    if [ "$found" = false ]; then
      local local_path="$HOME/.config/fzf"
      mkdir -p "$local_path"
      {{- if not (index . "is_offline") }}
      if command -v curl >/dev/null; then
        echo "fzf integration files missing. Downloading to $local_path..."
        curl -sSL -o "$local_path/completion.zsh" https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh
        curl -sSL -o "$local_path/key-bindings.zsh" https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh
        [ -f "$local_path/completion.zsh" ] && source "$local_path/completion.zsh"
        [ -f "$local_path/key-bindings.zsh" ] && source "$local_path/key-bindings.zsh"
      fi
      {{- end }}
    fi
  }
fi
```

- [ ] **Step 2: Verify template rendering**

Run: `chezmoi execute-template < dot_zshrc.tmpl | grep -A 30 "# fzf"`
Expected: Rendered output shows the new logic, including the `curl` commands.

- [ ] **Step 3: Commit**

```bash
git add .chezmoitemplates/zsh_post_setup
git commit -m "feat: add self-healing fzf shell integration"
```

---

### Task 2: Add fzf Health Check

**Files:**
- Modify: `tests/health_check.bats`

- [ ] **Step 1: Add fzf keybinding check to `tests/health_check.bats`**

Add this test to the end of the file. We'll check if the `fzf-history-widget` (Ctrl+R) function is defined in an interactive shell.

```bash
@test "fzf keybindings are loaded" {
  run zsh -i -c "typeset -f fzf-history-widget > /dev/null && echo 'found'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"found"* ]]
}
```

- [ ] **Step 2: Run tests**

Run: `make update && make health`
Expected: `make update` triggers the download, and all 15 tests pass (including the fzf keybinding check).

- [ ] **Step 3: Commit**

```bash
git add tests/health_check.bats
git commit -m "test: add health check for fzf keybindings"
```
