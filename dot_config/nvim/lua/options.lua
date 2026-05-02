-- dot_config/nvim/lua/options.lua
-- This file is managed by chezmoi

require "nvchad.options"

local opt = vim.opt

-- Custom options
opt.relativenumber = true

-- Targeted suppression of noisy deprecation warnings
local original_notify = vim.notify
vim.notify = function(msg, level, opts)
  if msg:find "The `require('lspconfig')` \"framework\" is deprecated" then
    return
  end
  original_notify(msg, level, opts)
end
