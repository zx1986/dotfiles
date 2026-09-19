# AI Tools Chezmoi Integration — Design Spec

**Date**: 2026-09-20
**Scope**: macOS only (Linux deferred)
**Goal**: Register AI-related CLI tools into chezmoi's automated installation pipeline so that `make init` on a new Mac brings up the full AI toolkit, and `make update` picks up newly added tools.

---

## Context

The xProfile dotfiles project uses chezmoi to manage dotfiles across macOS and Ubuntu. AI agent tools are currently installed in two ways:

1. **Antigravity plugins** — Managed via `.chezmoidata.yaml` → `run_once_before_06_install_antigravity.sh.tmpl`. Already handles: superpowers, ponytail, mattpocock/skills.
2. **npm globals / npx skills** — Installed manually, not tracked by dotfiles. Currently includes: `@colbymchenry/codegraph`, `neovim` (npm). Archify is not yet installed.

This spec adds a new chezmoi-managed installation layer for tools distributed via language-specific package managers (npm, npx). Future categories (pipx, gem, go install) will be added when actually needed (YAGNI).

## Design Principles

- **"Install tools, not development environments"** — Homebrew provides language runtimes; language-specific package managers install CLI tools. Development happens in dev containers.
- **Data-driven** — `.chezmoidata.yaml` declares what to install; scripts define how.
- **Don't repeat yourself** — Homebrew packages stay in `run_once_before_00`. Antigravity plugins stay in `06`. This new script only handles language package managers.
- **Graceful degradation** — If a package manager is missing, warn and skip (don't fail the entire init).
- **Offline-aware** — Respect the existing `is_offline` flag; skip all network-dependent installs when offline.
- **Incremental updates** — Use `run_onchange` so adding a new tool to YAML + `make update` triggers installation automatically.

## Changes

### 1. `.chezmoidata.yaml` — New `ai_tools` section + plugin cleanup

Add `ai_tools` section after the existing `antigravity` section:

```yaml
ai_tools:
  npm_globals:
    - "@colbymchenry/codegraph"
    - neovim
  npx_skills:
    - "tt-a1i/archify"
```

Remove `Egonex-AI/Understand-Anything` from `antigravity.plugins`:

```yaml
antigravity:
  plugins:
    - https://github.com/obra/superpowers
    - https://github.com/DietrichGebert/ponytail
    - https://github.com/mattpocock/skills
    # Removed: https://github.com/Egonex-AI/Understand-Anything
```

**Rules:**
- Each key corresponds to a package manager category.
- A missing key means "nothing to install" for that category.
- Items are package identifiers as accepted by the respective package manager.
- No version pinning — always install latest. These are CLI tools, not application dependencies.

### 2. `run_onchange_before_07_install_ai_tools.sh.tmpl` — New install script

A new chezmoi `run_onchange_before` script, numbered `07` to run after antigravity plugin installation (06) and after Homebrew packages are available (00).

**Why `run_onchange` instead of `run_once`**: The script is a chezmoi template that references `.chezmoidata.yaml` data. When the YAML changes, the rendered script content changes, and chezmoi detects this and re-runs the script. This means adding a new tool to the YAML and running `make update` will automatically install it.

**macOS-only guard**: The script body is wrapped in a `{{ if eq .chezmoi.os "darwin" }}` block. Linux support can be added later.

**Offline guard**: All installation commands are wrapped in `{{ if not (index . "is_offline") }}`.

**Script logic (pseudocode):**

```
# --- npm globals ---
if command -v npm exists:
  for each package in .ai_tools.npm_globals:
    npm list -g <package> || npm install -g <package>
else:
  warn "npm not found, skipping npm globals"

# --- npx skills ---
if command -v npx exists:
  for each skill in .ai_tools.npx_skills:
    npx -y skills add <skill> -g --yes
else:
  warn "npx not found, skipping npx skills"
```

**Idempotency**: For npm globals, check `npm list -g <package>` before installing to avoid unnecessary reinstalls. The `run_onchange` mechanism handles detecting when the tool list changes; the idempotency check avoids redundant npm operations within a single run.

### 3. Rename `run_once_before_06` → `run_onchange_before_06`

Rename the existing antigravity install script from `run_once_before_06_install_antigravity.sh.tmpl` to `run_onchange_before_06_install_antigravity.sh.tmpl`. This ensures that adding a new plugin to `.chezmoidata.yaml` and running `make update` will automatically install it.

No content changes to the script — only the filename changes.

### 4. `.chezmoiignore` — No changes needed

The new script is a `run_onchange_before_*` file at the repo root, which chezmoi processes automatically.

### 5. Tests

**Template rendering tests** (`tests/suite_common.sh` or `tests/suite_macos.sh`):
- Verify the rendered `07_install_ai_tools.sh` contains `npm install -g` commands for each `npm_globals` item.
- Verify the rendered script contains `npx` commands for each `npx_skills` item.
- Verify offline-mode rendering skips all installation commands.

**Health check** (`tests/health_check.bats`):
- Add assertions that `codegraph` CLI is available and executable.
- Add assertion that `archify` or its skills entry is present.

## What This Spec Does NOT Cover

- **Linux support** — Deferred. The script template has a Darwin-only guard.
- **MCP server configuration** — `~/.gemini/settings.json` is not managed by dotfiles. The codegraph MCP entry stays manually maintained.
- **Removing existing npm globals** (e.g., `happy-coder`) — User handles manually.
- **asdf changes** — No changes to asdf configuration or `.tool-versions`.
- **Homebrew package list changes** — If Go needs to be added to brew, that goes in `run_once_before_00`, not here.
- **Future package manager categories** (pipx, gem, go install) — Will be added to YAML and script when actually needed.

## File Changes Summary

| File | Action |
|---|---|
| `.chezmoidata.yaml` | Add `ai_tools` section; remove Understand-Anything from plugins |
| `run_onchange_before_07_install_ai_tools.sh.tmpl` | Create new file |
| `run_once_before_06_install_antigravity.sh.tmpl` | Rename to `run_onchange_before_06_install_antigravity.sh.tmpl` |
| `tests/suite_common.sh` or `tests/suite_macos.sh` | Add template rendering assertions |
| `tests/health_check.bats` | Add codegraph / archify health checks |

## Responsibility Separation

```
00_install_packages       →  brew install (runtimes + system tools)     [run_once]
06_install_antigravity    →  agy plugin install (agent plugins)         [run_onchange]
07_install_ai_tools       →  npm -g / npx skills (CLI tools)           [run_onchange]
```
