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
