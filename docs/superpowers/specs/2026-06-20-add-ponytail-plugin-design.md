# Design Spec: Add Ponytail Antigravity Plugin

## Overview

This specification details adding the `ponytail` Antigravity plugin to the dotfiles configuration so it is automatically installed during Chezmoi initialization and update.

## Context

* **Repository**: xProfile
* **Goal**: Add `https://github.com/DietrichGebert/ponytail` to `antigravity.plugins` in `.chezmoidata.yaml`.

---

## Proposed Changes

### 1. `.chezmoidata.yaml`

Modify `.chezmoidata.yaml` to include the new plugin in the list:

```yaml
antigravity:
  plugins:
    - https://github.com/obra/superpowers
    - https://github.com/DietrichGebert/ponytail
```

---

## Verification Plan

1. Run `make update` (or `chezmoi apply`) to trigger Chezmoi update.
2. Verify that `agy plugin install` runs and successfully installs `https://github.com/DietrichGebert/ponytail`.
