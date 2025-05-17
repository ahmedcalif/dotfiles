return {
  "stevearc/conform.nvim",
  config = function()
    vim.g.disable_autoformat = false
    require("conform").setup({
      formatters_by_ft = {
        purescript = { "purstidy" },
        lua = { "stylua" },
        ocaml = { "ocamlformat" },
        python = { "black" },
        rust = { "rustfmt" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        astro = { "astro" },
        go = { "gofumpt", "golines", "goimports-reviser" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        haskell = { "ormolu" },
        yaml = { "yamlfmt" },
        html = { "prettier" },
        json = { "prettier" },
        markdown = { "prettier" },
        gleam = { "gleam" },
        asm = { "asmfmt" },
        css = { "prettier" },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat then
          return
        end
        return {
          timeout_ms = 1000, -- Increased timeout
          lsp_fallback = true,
        }
      end,
    })
  end,
}
