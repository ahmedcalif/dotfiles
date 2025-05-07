return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- Choose from: latte, frappe, macchiato, mocha
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false, -- Set to true if you want transparency
        show_end_of_buffer = false,
        term_colors = true,
        dim_inactive = {
          enabled = false,
          percentage = 0.15,
        },
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        color_overrides = {
          mocha = {
            -- You can override specific colors here
            -- base = "#000000",
            -- mantle = "#000000",
            -- crust = "#000000",
          },
        },
        custom_highlights = function(colors)
          return {
            -- Add custom highlight overrides here
            -- Example:
            -- Comment = { fg = colors.flamingo },
          }
        end,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          telescope = true,  -- This is important for Telescope styling
          which_key = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
          },
          -- For more plugin integrations see https://github.com/catppuccin/nvim#integrations
          
          -- Special integrations
          dashboard = true,
          lsp_trouble = true,
        }
      })
      
      -- Set colorscheme after options
      vim.cmd.colorscheme "catppuccin"
    end,
  }
}