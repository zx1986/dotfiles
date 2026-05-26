# Design Doc: Switch from diff-so-fancy to delta

## Problem
The user reported an error: `diff-so-fancy: not found`. This tool was referenced in `.gitconfig.tmpl` but not installed by any setup scripts.

## Proposed Solution
Switch from `diff-so-fancy` to `delta` (git-delta), which is a more modern and feature-rich diff highlighter.

## Changes

### 1. Installation Scripts
- **Universal**: Add `asdf plugin add delta` to `run_once_before_00_install_packages.sh.tmpl` and add `delta 0.18.2` to `dot_tool-versions`. This ensures `delta` is managed consistently via `asdf` on both macOS and Linux, avoiding redundant installations via platform-specific package managers like Homebrew.

### 2. Git Configuration
Update `dot_gitconfig.tmpl` to:
- Set `pager.diff` and `pager.show` to `delta`.
- Add a `[delta]` section with recommended settings (navigate, line-numbers, side-by-side).
- Set `interactive.diffFilter` to `delta --color-only`.
- Remove legacy `diff-highlight` color settings that were tuned for `diff-so-fancy`.

## Verification Plan
- Verify that `chezmoi apply` successfully updates the files.
- (Manual) Verify that `delta` is installed after running the install scripts.
- (Manual) Run `git diff` to see the new `delta` output.
