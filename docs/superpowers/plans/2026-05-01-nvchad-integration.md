# NvChad v2.5 Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Integrate NvChad v2.5 into the chezmoi-managed dotfiles to provide a modern Neovim environment.

**Architecture:** A two-stage bootstrap process. First, system dependencies (Neovim 0.10+, ripgrep, fd, gcc) are installed via Homebrew. Second, the NvChad starter repository is cloned into `~/.config/nvim`. Chezmoi then manages and overwrites key configuration files in the `lua/` directory.

**Tech Stack:** Neovim 0.10+, Homebrew, Git, Lua, NvChad v2.5 Starter.

---

### Task 1: Update Package Installation

**Files:**
- Modify: `run_once_install_packages.sh.tmpl`

- [x] **Step 1: Add Neovim and dependencies to Brew installation**

Modify the macOS section to include `neovim`, `ripgrep`, `fd`, and `gcc`.

```bash
# ... existing code ...
echo "Installing Brew Packages..."
brew install git tig bit-git curl asdf zsh coreutils gemini-cli neovim ripgrep fd gcc
# ... existing code ...
```

- [x] **Step 2: Commit changes**

```bash
git add run_once_install_packages.sh.tmpl
git commit -m "feat(nvchad): add neovim and dependencies to package installer"
```

---

### Task 2: Create NvChad Bootstrap Script

**Files:**
- Create: `run_once_install_nvchad.sh.tmpl`

- [x] **Step 1: Create the installation script**

This script will clone the NvChad starter if `~/.config/nvim` does not exist.

```bash
#!/bin/bash

# NvChad v2.5 installation script
# https://nvchad.com/docs/quickstart/install

if [ ! -d "$HOME/.config/nvim" ]; then
  echo "Installing NvChad v2.5 starter..."
  git clone https://github.com/NvChad/starter "$HOME/.config/nvim"
else
  echo "NvChad (or existing nvim config) already exists at $HOME/.config/nvim. Skipping clone."
fi
```

- [x] **Step 2: Ensure the script is executable**

Run: `chmod +x run_once_install_nvchad.sh.tmpl`

- [x] **Step 3: Commit changes**

```bash
git add run_once_install_nvchad.sh.tmpl
git commit -m "feat(nvchad): add run_once script to clone NvChad starter"
```

---

### Task 3: Create Managed Configuration Files

**Files:**
- Create: `dot_config/nvim/lua/chadrc.lua`
- Create: `dot_config/nvim/lua/options.lua`
- Create: `dot_config/nvim/lua/mappings.lua`
- Create: `dot_config/nvim/lua/plugins/init.lua`

- [x] **Step 1: Create `chadrc.lua`**

This is the main NvChad config entry point.

```lua
-- dot_config/nvim/lua/chadrc.lua
-- This file is managed by chezmoi

local M = {}

M.ui = {
  theme = "onedark",
}

M.plugins = "plugins"

M.mappings = require "mappings"

return M
```

- [x] **Step 2: Create `options.lua`**

```lua
-- dot_config/nvim/lua/options.lua
-- This file is managed by chezmoi

require "nvchad.options"

local opt = vim.opt

-- Custom options
opt.relativenumber = true
```

- [x] **Step 3: Create `mappings.lua`**

```lua
-- dot_config/nvim/lua/mappings.lua
-- This file is managed by chezmoi

local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
  },
}

-- Add more mappings here

return M
```

- [x] **Step 4: Create `plugins/init.lua`**

```lua
-- dot_config/nvim/lua/plugins/init.lua
-- This file is managed by chezmoi

local plugins = {
  {
    "stevearc/conform.nvim",
    --  for concatenation or format on save
    -- config = function()
    --   require "configs.conform"
    -- end,
  },

  -- Override plugin configs
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "nvchad.configs.lspconfig"
      require "configs.lspconfig"
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "html-lsp",
        "css-lsp",
        "prettier",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
      },
    },
  },
}

return plugins
```

- [x] **Step 5: Create a placeholder `configs/lspconfig.lua` (if referenced)**

Since `plugins/init.lua` references `configs.lspconfig`, we should ensure it exists or remove the reference. I'll create a minimal one.

```lua
-- dot_config/nvim/lua/configs/lspconfig.lua
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local servers = { "html", "cssls" }

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end
```

- [x] **Step 6: Commit all config files**

```bash
git add dot_config/nvim/lua/
git commit -m "feat(nvchad): add managed lua configuration files"
```

---

### Task 4: Verification

- [x] **Step 1: Run `chezmoi apply`**

Run: `chezmoi apply -v`
Expected: Files are symlinked/copied to `~/.config/nvim/lua/`, and `nvim` is installed.

- [x] **Step 2: Launch Neovim**

Run: `nvim`
Expected: NvChad splash screen appears, Lazy.nvim starts installing plugins.

- [x] **Step 3: Verify custom options**

Inside nvim: `:set relativenumber?`
Expected: `relativenumber`

- [x] **Step 4: Verify mappings**

Press `;` in normal mode.
Expected: Enters command mode (equivalent to `:`).

- [x] **Step 5: Check health**

Inside nvim: `:checkhealth`
Expected: No critical errors for NvChad dependencies.
