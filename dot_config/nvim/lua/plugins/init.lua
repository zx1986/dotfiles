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
