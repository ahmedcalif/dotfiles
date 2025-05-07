return {
  -- Configure built-in diagnostics
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      -- Optional dependencies for better experience
      "folke/lsp-colors.nvim",
    },
    config = function()
      -- Enhanced diagnostic display
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●", -- or "■", "▎", etc
          spacing = 4,
          source = "always",
          severity = {
            min = vim.diagnostic.severity.HINT,
          },
        },
        float = {
          source = "always",
          border = "rounded",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Better signs in the gutter
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end
    end,
  },

  -- For an even more enhanced experience, you can add:
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "TroubleToggle", "Trouble" },
    opts = {
      position = "bottom",
      icons = true,
      mode = "document_diagnostics",
      auto_preview = true,
      auto_close = true,
    },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle<cr>",                       desc = "Toggle Trouble" },
      { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>",  desc = "Document Diagnostics" },
      { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
    },
  },
}
