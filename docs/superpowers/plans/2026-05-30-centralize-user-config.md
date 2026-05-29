# Centralize User Configuration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Centralize user identity (name, email, username) in `.chezmoidata.yaml` for use in chezmoi templates.

**Architecture:** Add a `user` block to the top-level of `.chezmoidata.yaml`.

**Tech Stack:** YAML, Python (for validation)

---

### Task 1: Update `.chezmoidata.yaml`

**Files:**
- Modify: `.chezmoidata.yaml`

- [ ] **Step 1: Add user info to `.chezmoidata.yaml`**

Add the `user` block to the end of the file.

```yaml
user:
  name: "張旭"
  email: "zx1986@gmail.com"
  username: "zx1986"
```

- [ ] **Step 2: Verify YAML syntax**

Run: `python3 -c 'import yaml, sys; yaml.safe_load(open(".chezmoidata.yaml"))'`
Expected: No output (exit code 0).

- [ ] **Step 3: Commit**

```bash
git add .chezmoidata.yaml
git commit -m "feat: centralize user config in .chezmoidata.yaml"
```
