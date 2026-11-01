# Antigravity Skills Declarative Sync — Design Spec

**Date**: 2026-11-02
**Scope**: macOS (with cross-platform `dot_gemini/config/skills.json` dotfile)
**Goal**: Consolidate `xProfile` AI tooling around Antigravity CLI (`agy`) by separating full plugins from pure skills, mounting `~/.agents/skills` into `agy` via `~/.gemini/config/skills.json`, and declaratively syncing `npx skills` packages from `.chezmoidata.yaml`.

---

## Context

Following a consolidation of `~/.gemini` and `~/.agents`, Antigravity CLI (`~/.local/bin/agy`) is the sole AI coding environment:

1. **Full Plugins (`~/.gemini/config/plugins/`)**: Only packages requiring hooks, commands, or subagents belong here. Built-in plugins (`firebase`, `modern-web-guidance-plugin`) are managed by `agy` itself; external plugins (`obra/superpowers`, `DietrichGebert/ponytail`) are installed via `agy plugin install`.
2. **Pure Skills (`~/.agents/skills/`)**: Pure `SKILL.md` directories live in `~/.agents/skills/` and are managed by `npx skills` (`-g -a antigravity-cli`). `mattpocock/skills` was previously installed as a plugin, where its nested category subdirectories (`skills/engineering/*`, etc.) prevented `agy`'s one-level skill scanner from discovering them and included unwanted categories (`deprecated`, `in-progress`, `personal`).
3. **Skill Discovery (`~/.gemini/config/skills.json`)**: `agy` does not scan `~/.agents/skills` by default. Declaring `{"entries": [{"path": "~/.agents/skills"}]}` in `~/.gemini/config/skills.json` mounts all global skills into `agy`.
4. **Tool-Managed Files Left Untracked**: `~/.gemini/GEMINI.md` and `~/.gemini/config/mcp_config.json` are maintained by `codegraph`; `~/.gemini/config/config.json` and `~/.gemini/antigravity-cli/settings.json` are mutated by `agy` at runtime. None of these are tracked by chezmoi (YAGNI).

---

## Changes

### 1. `dot_gemini/config/skills.json` — Mount `~/.agents/skills` in `agy`

Create `dot_gemini/config/skills.json` so chezmoi manages `~/.gemini/config/skills.json`:

```json
{
  "entries": [
    { "path": "~/.agents/skills" }
  ]
}
```

### 2. `.chezmoidata.yaml` — Separate Plugins and Structured `npx_skills`

Update `antigravity.plugins` and `ai_tools.npx_skills`:

- Remove `https://github.com/mattpocock/skills` from `antigravity.plugins` (now managed as curated pure skills).
- Replace `tt-a1i/archify` in `ai_tools.npx_skills` with a structured list of `{ repo, skills }` entries representing the 27 curated skills (26 from `mattpocock/skills`, 1 from `vercel-labs/skills`):

```yaml
antigravity:
  plugins:
    - https://github.com/obra/superpowers
    - https://github.com/DietrichGebert/ponytail

ai_tools:
  npm_globals:
    - "@colbymchenry/codegraph"
    - neovim
  npx_skills:
    - repo: "mattpocock/skills"
      skills:
        - ask-matt
        - code-review
        - codebase-design
        - diagnosing-bugs
        - domain-modeling
        - git-guardrails-claude-code
        - grill-me
        - grill-with-docs
        - grilling
        - handoff
        - implement
        - improve-codebase-architecture
        - migrate-to-shoehorn
        - prototype
        - research
        - resolving-merge-conflicts
        - scaffold-exercises
        - setup-matt-pocock-skills
        - setup-pre-commit
        - tdd
        - teach
        - to-spec
        - to-tickets
        - triage
        - wayfinder
        - writing-great-skills
    - repo: "vercel-labs/skills"
      skills:
        - find-skills
```

### 3. `run_onchange_before_07_install_ai_tools.sh.tmpl` — Declarative Sync for `npx_skills`

Update the `# --- npx skills ---` section in `run_onchange_before_07_install_ai_tools.sh.tmpl` to perform two-way declarative synchronization against `~/.agents/skills`:

1. **Install Missing Skills (Per-Repo Batching)**:
   For each entry in `.ai_tools.npx_skills`, check which declared skills are missing from `$HOME/.agents/skills/<skill>`. If one or more skills from that `repo` are missing, run:
   ```bash
   npx -y skills add "{{ .repo }}" -g -a antigravity-cli -s "${missing_skills[@]}" -y
   ```
   If all skills for that `repo` are already present in `$HOME/.agents/skills/`, skip the network call.

2. **Prune Unlisted Skills (Strict Sync)**:
   Build the complete allowlist of declared skill names from `.ai_tools.npx_skills`. Scan `$HOME/.agents/skills/*` (directories only); any installed skill directory not in the allowlist is removed via:
   ```bash
   npx -y skills remove -g -s "${extra_skills[@]}" -y
   ```

### 4. `.gitignore` — Ignore Local `.codegraph/`

Add `.codegraph/` to `xProfile`'s `.gitignore` (and `.chezmoiignore`) so local CodeGraph SQLite indexes inside the `xProfile` repository are never tracked or deployed into `$HOME`.

### 5. Tests (`tests/suite_common.sh` & `tests/health_check.bats`)

- **`tests/suite_common.sh`**:
  - Verify `$TMP_HOME/.gemini/config/skills.json` is rendered and references `~/.agents/skills`.
  - Replace the `mattpocock/skills` check on `06_install_antigravity.sh` with assertions for `obra/superpowers` and `DietrichGebert/ponytail`, plus a negative check (`! grep -q 'mattpocock/skills'`).
  - Replace the `tt-a1i/archify` check on `07_install_ai_tools.sh` with assertions for `mattpocock/skills`, `vercel-labs/skills`, `-a antigravity-cli`, and `skills remove -g`.
- **`tests/health_check.bats`**:
  - Verify `~/.gemini/config/skills.json` exists.
  - Verify `~/.agents/skills` directory exists and contains expected skills (e.g., `tdd`, `find-skills`).

---

## File Changes Summary

| File | Action |
|---|---|
| `dot_gemini/config/skills.json` | Create new file mounting `~/.agents/skills` |
| `.chezmoidata.yaml` | Remove `mattpocock/skills` from `antigravity.plugins`; update `ai_tools.npx_skills` to structured `{ repo, skills }` list |
| `run_onchange_before_07_install_ai_tools.sh.tmpl` | Implement missing-skill batch install + declarative prune using `npx -y skills` |
| `.gitignore` & `.chezmoiignore` | Ignore `.codegraph/` |
| `tests/suite_common.sh` | Update template rendering assertions for `skills.json`, `06_install_antigravity.sh`, and `07_install_ai_tools.sh` |
| `tests/health_check.bats` | Add health checks for `~/.gemini/config/skills.json` and `~/.agents/skills` |
