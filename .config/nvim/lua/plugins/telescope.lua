return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      'nvim-telescope/telescope-ui-select.nvim',
      'nvim-telescope/telescope-file-browser.nvim',
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      local themes = require('telescope.themes')
      
      telescope.setup({
        defaults = {
          prompt_prefix = "  ",
          selection_caret = "  ",
          path_display = { "truncate" },
          file_ignore_patterns = { "node_modules", ".git/", "dist" },
          layout_strategy = 'horizontal',
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.45,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          sorting_strategy = "ascending",
          mappings = {
            i = {
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-c>"] = actions.close,
              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<PageUp>"] = actions.results_scrolling_up,
              ["<PageDown>"] = actions.results_scrolling_down,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-l>"] = actions.complete_tag,
              ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
            },
            n = {
              ["<esc>"] = actions.close,
              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
              ["H"] = actions.move_to_top,
              ["M"] = actions.move_to_middle,
              ["L"] = actions.move_to_bottom,
              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
              ["gg"] = actions.move_to_top,
              ["G"] = actions.move_to_bottom,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<PageUp>"] = actions.results_scrolling_up,
              ["<PageDown>"] = actions.results_scrolling_down,
              ["?"] = actions.which_key,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            theme = "dropdown",
            previewer = false,
            layout_config = {
              width = 0.6,
            },
          },
          live_grep = {
            theme = "ivy",
          },
          buffers = {
            theme = "dropdown",
            previewer = false,
            layout_config = {
              width = 0.6,
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,                    -- false will only do exact matching
            override_generic_sorter = true,  -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
          },
          ["ui-select"] = {
            themes.get_dropdown {
              -- even more opts
            }
          },
          file_browser = {
            theme = "dropdown",
            hijack_netrw = true,
          },
        }
      })
      
      -- Load extensions
      telescope.load_extension('fzf')
      telescope.load_extension('ui-select')
      telescope.load_extension('file_browser')
      
      -- Set keymaps
      local keymap = vim.keymap.set
      
      keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
      keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
      keymap("n", "<leader>fb", "<cmd>Telescope file_browser<cr>", { desc = "File browser" })
      keymap("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
      keymap("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
      keymap("n", "<leader>fc", "<cmd>Telescope commands<cr>", { desc = "Commands" })
      keymap("n", "<leader>fm", "<cmd>Telescope marks<cr>", { desc = "Marks" })
      keymap("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Keymaps" })
      keymap("n", "<leader>:", "<cmd>Telescope command_history<cr>", { desc = "Command history" })
      keymap("n", "<leader>ft", "<cmd>Telescope treesitter<cr>", { desc = "Treesitter symbols" })
    end
  }
}