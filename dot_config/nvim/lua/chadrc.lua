-- dot_config/nvim/lua/chadrc.lua
-- This file is managed by chezmoi

local M = {}

M.ui = {
  theme = "onedark",
}

M.plugins = "plugins"

M.mappings = require "mappings"

return M
