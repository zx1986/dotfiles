-- dot_config/nvim/lua/options.lua
-- This file is managed by chezmoi

require "nvchad.options"

local opt = vim.opt

-- Custom options
opt.relativenumber = true

-- Silence deprecation warnings (e.g., from nvim-lspconfig on nightly versions)
vim.deprecate = function() end
