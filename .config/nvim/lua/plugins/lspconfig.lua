return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        PATH = "prepend",
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "bashls",
          "lua_ls",
          "html",
          "cssls",
          "emmet_language_server",
          "tailwindcss",
          "ts_ls",
          "astro",
          "tsserver",
          "clangd",
          "prismals",
          "yamlls",
          "jsonls",
          "eslint",
          "marksman", -- This is the markdown LSP
          "sqlls",
          "wgsl_analyzer",
          "texlab",
          "intelephense",
          "nim_langserver",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local lspconfig = require("lspconfig")
      local configs = require("lspconfig.configs")

      lspconfig.fortls.setup({
        capabilities = capabilities,
        root_dir = require("lspconfig").util.root_pattern("*.f90"),
      })
      lspconfig.purescriptls.setup({
        capabilities = capabilities,
        filetypes = { "purescript" },
        settings = {
          purescript = {
            addSpagoSources = true, -- e.g. any purescript language-server config here
          },
        },
        flags = {
  debounce_text_changes = 150,
    }
  }
  }
