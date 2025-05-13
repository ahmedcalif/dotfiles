-- Check for Neovim version compatibility
if vim.fn.has('nvim-0.10') == 0 then
  vim.api.nvim_echo({
    { "This config requires Neovim 0.10.0 or higher. Please update Neovim!", "ErrorMsg" },
    { "\nPress any key to continue with limited functionality..." },
  }, true, {})
  vim.fn.getchar()
end

-- Ensure utils module exists before requiring it
local utils_exists, utils = pcall(require, "utils")
if not utils_exists then
  -- Create minimal utils to prevent errors
  utils = {
    color_overrides = { setup_colorscheme_overrides = function() end },
    fix_telescope_parens_win = function() end,
    dashboard = { setup_dashboard_image_colors = function() end }
  }
end -- lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- vim opts (safely load)
local vimopts_exists, _ = pcall(require, "vimopts")
if not vimopts_exists then
  -- Set basic vim options if vimopts module doesn't exist
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.expandtab = true
  vim.g.mapleader = " "
end

-- Check and install dependencies
local function ensure_external_dependencies()
  local dependencies = {
    { "tree-sitter", "tree-sitter --help", "Tree-sitter CLI is required for syntax highlighting" },
    { "ripgrep",     "rg --version",       "Ripgrep is recommended for Telescope grep functionality" },
    { "fzf",         "fzf --version",      "FZF is required for fuzzy finding functionality" }
  }

  local missing_deps = {}
  for _, dep in ipairs(dependencies) do
    local success = os.execute(dep[2] .. " > /dev/null 2>&1")
    if success ~= 0 then
      table.insert(missing_deps, dep[3])
    end
  end

  if #missing_deps > 0 then
    vim.api.nvim_echo({
      { "Missing dependencies:\n", "WarningMsg" }
    }, true, {})

    for _, msg in ipairs(missing_deps) do
      vim.api.nvim_echo({
        { "- " .. msg .. "\n", "WarningMsg" }
      }, true, {})
    end
  end
end

-- Call dependency check
ensure_external_dependencies()

-- Define fallback plugins configuration if needed
local function setup_plugins_with_error_handling()
  local lazy_setup_success, err = pcall(function()
    -- lazy.nvim setup with error handling for plugin modules
    require("lazy").setup({
      -- Core plugins that should work without extra dependencies
      { "nvim-lua/plenary.nvim" },

      -- Catppuccin theme
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
            transparent_background = false,
            show_end_of_buffer = false,
            term_colors = true,
            dim_inactive = {
              enabled = false,
            },
            integrations = {
              cmp = true,
              gitsigns = true,
              telescope = true,
              treesitter = true,
              native_lsp = true,
            }
          })
        end
      },

      -- Basic core functionality
      {
        "nvim-telescope/telescope.nvim",
        dependencies = {
          "nvim-lua/plenary.nvim",
          {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
            cond = function()
              return vim.fn.executable("make") == 1
            end,
          },
        },
        config = function()
          -- Enhanced telescope config
          local telescope = require('telescope')
          local actions = require('telescope.actions')

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
                width = 0.87,
                height = 0.80,
                preview_cutoff = 120,
              },
              sorting_strategy = "ascending",
              mappings = {
                i = {
                  ["<C-j>"] = actions.move_selection_next,
                  ["<C-k>"] = actions.move_selection_previous,
                  ["<C-c>"] = actions.close,
                  ["<Down>"] = actions.move_selection_next,
                  ["<Up>"] = actions.move_selection_previous,
                  ["<CR>"] = actions.select_default,
                  ["<C-x>"] = actions.select_horizontal,
                  ["<C-v>"] = actions.select_vertical,
                },
              },
              -- Add explicit buffer_previewer_maker to fix errors
              buffer_previewer_maker = require('telescope.previewers').buffer_previewer_maker,
            },
            pickers = {
              find_files = {
                theme = "dropdown",
                previewer = false,
                layout_config = {
                  width = 0.6,
                },
              },
              live_grep = {
                theme = "ivy",
              },
            },
            extensions = {
              fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = "smart_case",
              },
            }
          })

          -- Load extensions if available
          pcall(function() telescope.load_extension('fzf') end)

          -- Basic telescope keymaps
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
          vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
          vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
          vim.keymap.set('n', '<leader>fb', builtin.buffers, {})

          -- Add file browser functionality using telescope
          -- This replaces dirbuf functionality
          vim.keymap.set('n', '<leader>fe', function()
            builtin.find_files({ cwd = vim.fn.expand('%:p:h') })
          end, { desc = "Browse files in current directory" })

          -- Add a command to browse the current directory
          vim.keymap.set('n', '<leader>n', function()
            builtin.find_files({ cwd = vim.fn.expand('%:p:h') })
          end, { desc = "Browse files in current file's directory" })
        end
      },

      -- Add junegunn/fzf and junegunn/fzf.vim for fzf integration
      {
        "junegunn/fzf",
        build = "./install --all",
      },
      {
        "junegunn/fzf.vim",
        dependencies = { "junegunn/fzf" },
        config = function()
          -- FZF configuration
          vim.g.fzf_layout = { window = { width = 0.9, height = 0.6 } }
          vim.g.fzf_preview_window = { 'right:50%', 'ctrl-/' }

          -- FZF key mappings for additional functionality
          vim.api.nvim_set_keymap('n', '<leader>fa', ':Files<CR>', { noremap = true, silent = true })
          vim.api.nvim_set_keymap('n', '<leader>fr', ':Rg<CR>', { noremap = true, silent = true })
          vim.api.nvim_set_keymap('n', '<leader>fz', ':FZF<CR>', { noremap = true, silent = true })
          vim.api.nvim_set_keymap('n', '<leader>ft', ':Tags<CR>', { noremap = true, silent = true })
          vim.api.nvim_set_keymap('n', '<leader>fm', ':Marks<CR>', { noremap = true, silent = true })

          -- Custom FZF command to navigate directories (replacement for dirbuf)
          vim.api.nvim_create_user_command("FZFExplore", function(opts)
            local dir = opts.args ~= "" and opts.args or vim.fn.expand('%:p:h')
            vim.cmd("Files " .. dir)
          end, { nargs = "?", complete = "dir" })

          -- Key mapping for FZF directory browser
          vim.api.nvim_set_keymap('n', '<leader>fb', ':FZFExplore<CR>', { noremap = true, silent = true })
          vim.api.nvim_set_keymap('n', '<leader>n', ':FZFExplore %:p:h<CR>', { noremap = true, silent = true })
        end
      },

      -- Add error-lens.nvim for inline error messages
      {
        "chikko80/error-lens.nvim",
        version = "*", -- Use latest stable version
        event = { "BufRead", "BufNewFile", "InsertEnter", "TextChanged", "TextChangedI" },
        dependencies = {
          "nvim-telescope/telescope.nvim",
          {
            "nvim-lspconfig",
            config = function()
              -- Basic LSP setup
              local lspconfig = require('lspconfig')

              -- Common LSP configuration for faster diagnostics
              local common_config = {
                flags = {
                  debounce_text_changes = 100, -- Faster updates when typing
                },
                init_options = {
                  provideFormatter = true,
                },
              }

              -- TypeScript/JavaScript server setup with faster diagnostics
              lspconfig.tsserver.setup {
                settings = {
                  typescript = {
                    suggest = { enabled = true },
                    format = { enabled = true },
                    updateImportsOnFileMove = { enabled = "always" },
                    inlayHints = {
                      includeInlayParameterNameHints = "all",
                      includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                      includeInlayFunctionParameterTypeHints = true,
                      includeInlayVariableTypeHints = true,
                      includeInlayPropertyDeclarationTypeHints = true,
                      includeInlayFunctionLikeReturnTypeHints = true,
                      includeInlayEnumMemberValueHints = true,
                    },
                  },
                  javascript = {
                    suggest = { enabled = true },
                    format = { enabled = true },
                    updateImportsOnFileMove = { enabled = "always" },
                    inlayHints = {
                      includeInlayParameterNameHints = "all",
                      includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                      includeInlayFunctionParameterTypeHints = true,
                      includeInlayVariableTypeHints = true,
                      includeInlayPropertyDeclarationTypeHints = true,
                      includeInlayFunctionLikeReturnTypeHints = true,
                      includeInlayEnumMemberValueHints = true,
                    },
                  },
                },
                flags = common_config.flags,
              }

              -- C# setup (using omnisharp-lsp)
              lspconfig.omnisharp.setup {
                cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
                flags = common_config.flags,
                settings = {
                  omnisharp = {
                    useModernNet = true,
                    analyzeOpenDocumentsOnly = false,
                    enableImportCompletion = true,
                    enableRoslynAnalyzers = true,
                  },
                },
                -- Enable inlay hints for C# if available
                handlers = {
                  ["textDocument/publishDiagnostics"] = vim.lsp.with(
                    vim.lsp.diagnostic.on_publish_diagnostics, {
                      virtual_text = true,
                      signs = true,
                      underline = true,
                      update_in_insert = true, -- Critical for immediate feedback
                    }
                  ),
                },
              }

              -- PHP setup (using intelephense)
              lspconfig.intelephense.setup {
                flags = common_config.flags,
                settings = {
                  intelephense = {
                    diagnostics = {
                      run = "onType", -- Enable real-time diagnostics
                      undefinedTypes = true,
                      undefinedFunctions = true,
                      undefinedConstants = true,
                      undefinedProperties = true,
                      undefinedVariables = true,
                    },
                    format = {
                      enable = true,
                    },
                  },
                },
              }
              -- Add this to your lspconfig setup section
              lspconfig.tailwindcss.setup {
                flags = {
                  debounce_text_changes = 100,
                },
                settings = {
                  tailwindCSS = {
                    validate = true,
                    lint = {
                      cssConflict = "warning",
                      invalidApply = "error",
                      invalidScreen = "error",
                      invalidVariant = "error",
                      invalidConfigPath = "error",
                      invalidTailwindDirective = "error",
                    },
                    classAttributes = {
                      "class", "className", "classList", "ngClass"
                    },
                    experimental = {
                      classRegex = {
                        "class\\s*=\\s*[\\\"\\']([^\\\"\\']*)[\\\"\\']",
                        "className\\s*=\\s*[\\\"\\']([^\\\"\\']*)[\\\"\\']",
                        "tw\\s*`([^`]*)`",
                        "tw\\(['\"](.*)['\"]\\)"
                      }
                    }
                  }
                }
              }
            end
          },
        },
        config = function()
          require("error-lens").setup({
            -- Configuration options with sane defaults
            enabled = true,
            auto_adjust = {
              enable = false, -- Disable auto_adjust to avoid issues
            },
            prefix = "  ",    -- Could be '●', '▎', 'x', '■', , or any other character

            -- Enable updating errors as you type
            update_in_insert = true,

            -- Default colors (matching your colorscheme better is recommended)
            colors = {
              error_fg = "#FF6363",
              error_bg = "#342c2c",
              warn_fg = "#FFAD33",
              warn_bg = "#342f27",
              info_fg = "#65CCFF",
              info_bg = "#242d33",
              hint_fg = "#AAAAFF",
              hint_bg = "#2c2e3e",
            }
          })
        end
      },

      -- Load the rest of plugins
      { import = "plugins" },
    }, {
      defaults = {
        lazy = false,
      },
      -- Add checker for plugin health
      checker = {
        enabled = true,
        notify = false,
      },
      -- Better error handling for plugin problems
      performance = {
        rtp = {
          disabled_plugins = {
            "gzip",
            "tarPlugin",
            "tohtml",
            "tutor",
            "zipPlugin",
          },
        },
      },
    })
  end)

  if not lazy_setup_success then
    vim.api.nvim_echo({
      { "Error loading plugins: ", "ErrorMsg" },
      { tostring(err),             "WarningMsg" },
    }, true, {})

    -- Set up minimal plugins as fallback
    require("lazy").setup({
      { "nvim-lua/plenary.nvim" },
      {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
          vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
        end
      },
      {
        "junegunn/fzf",
        build = "./install --all"
      },
      {
        "junegunn/fzf.vim",
        dependencies = { "junegunn/fzf" },
        config = function()
          vim.api.nvim_set_keymap('n', '<leader>fb', ':FZF<CR>', { noremap = true, silent = true })
        end
      }
    })
  end
end

-- Set up plugins with error handling
setup_plugins_with_error_handling()

vim.filetype.add({ extension = { templ = "templ" } })
vim.filetype.add({ extension = { purs = "purescript" } })
vim.filetype.add({
  extension = { nim = "nim" },
  filename = { ["Nim"] = "nim" },
})

-- stop zig qf list from opening
vim.g.zig_fmt_parse_errors = 0

-- treesitter config with error handling - MODIFIED to disable incremental selection
local function setup_treesitter()
  local ts_success, config = pcall(require, "nvim-treesitter.configs")
  if not ts_success then
    vim.notify("Treesitter not available, skipping configuration", vim.log.levels.WARN)
    return
  end

  config.setup({
    ignore_install = {},
    ensure_installed = {
      "vimdoc", "lua", -- Keep only essentials for initial setup
      -- You can add more languages back gradually as they get installed
    },
    highlight = {
      enable = true,
    },
    indent = { enable = true },
    modules = {},
    sync_install = true,
    auto_install = true,
    -- IMPORTANT: Completely disable incremental selection to fix double key press issues
    incremental_selection = {
      enable = false,
    },
  })
end

-- Set up treesitter with error handling
setup_treesitter()

-- Load additional modules with error handling
local function safe_require(module)
  local success, result = pcall(require, module)
  if not success then
    vim.notify("Could not load " .. module, vim.log.levels.WARN)
  end
  return success
end

-- Try to load additional modules
safe_require("cool_stuff")
safe_require("mappings")

-- Apply colorscheme with fallback
local function set_colorscheme()
  if utils.color_overrides and utils.color_overrides.setup_colorscheme_overrides then
    utils.color_overrides.setup_colorscheme_overrides()
  end

  -- First try Catppuccin
  local colorscheme_success, _ = pcall(vim.cmd, "colorscheme catppuccin")
  if not colorscheme_success then
    vim.notify("Catppuccin colorscheme not found, trying other themes", vim.log.levels.WARN)

    -- Then try your previous theme
    local base16_success, _ = pcall(vim.cmd, "colorscheme base16-black-metal-gorgoroth")
    if not base16_success then
      -- Finally, fall back to habamax as a last resort
      vim.notify("Falling back to default theme", vim.log.levels.WARN)
      pcall(vim.cmd, "colorscheme habamax")
    end
  end
end

-- Apply colorscheme
set_colorscheme()

-- Apply any remaining utilities if they exist
if utils.fix_telescope_parens_win then
  utils.fix_telescope_parens_win()
end

if utils.dashboard and utils.dashboard.setup_dashboard_image_colors then
  utils.dashboard.setup_dashboard_image_colors()
end

-- Add basic keymaps for Telescope if they weren't added elsewhere
if not vim.fn.hasmapto('<leader>ff', 'n') then
  local builtin_exists, builtin = pcall(require, 'telescope.builtin')
  if builtin_exists then
    vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
  end
end
vim.opt.clipboard = "unnamedplus"

vim.api.nvim_set_keymap('v', '<C-c>', '"+y', { noremap = true, silent = true })

-- Ctrl+V to paste in normal mode
vim.api.nvim_set_keymap('n', '<C-v>', '"+p', { noremap = true, silent = true })

-- Ctrl+V to paste in insert mode
vim.api.nvim_set_keymap('i', '<C-v>', '<C-r>+', { noremap = true, silent = true })

-- Ctrl+X to cut in visual mode
vim.api.nvim_set_keymap('v', '<C-x>', '"+d', { noremap = true, silent = true })

-- Map Ctrl+S to save in normal, insert, and visual modes
vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-s>', '<Esc>:w<CR>a', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-s>', '<Esc>:w<CR>gv', { noremap = true, silent = true })

-- Comprehensive fix for double key press issues
local function fix_double_key_presses()
  -- 1. Delete any existing mappings for CR and BS in all modes
  for _, mode in ipairs({ 'n', 'i', 'v', 'x', 's', 'o', 't', 'c' }) do
    pcall(vim.keymap.del, mode, '<CR>', {})
    pcall(vim.keymap.del, mode, '<BS>', {})
  end

  -- 2. Reset Enter and Backspace to their default behaviors
  -- These should be as close to Vim's defaults as possible
  vim.keymap.set('i', '<CR>', '<CR>', { noremap = true, silent = true })
  vim.keymap.set('i', '<BS>', '<BS>', { noremap = true, silent = true })

  -- 3. Create diagnostic command to check for any plugins that might be capturing keys
  vim.api.nvim_create_user_command("DiagnoseKeyIssues", function()
    -- Print current autocommands that might be affecting <CR> or <BS>
    print("=== Checking for autocommands affecting <CR> or <BS> ===")
    vim.cmd("verbose autocmd InsertEnter")
    vim.cmd("verbose autocmd InsertLeave")
    vim.cmd("verbose autocmd TextChangedI")

    -- Print current key mappings for <CR> and <BS>
    print("\n=== Current mappings for <CR> and <BS> ===")
    for _, mode in ipairs({ 'n', 'i', 'v' }) do
      local maps = vim.api.nvim_get_keymap(mode)
      for _, map in ipairs(maps) do
        if map.lhs == "<CR>" or map.lhs == "<BS>" then
          print(mode .. " mode: " .. vim.inspect(map))
        end
      end
    end

    -- Check for common plugins that might cause issues
    print("\n=== Checking for potentially problematic plugins ===")
    local plugin_list = {
      "nvim-autopairs", "auto-pairs", "delimitMate", "pear-tree",
      "lexima.vim", "endwise", "cmp"
    }
    for _, plugin in ipairs(plugin_list) do
      local loaded = pcall(require, string.gsub(plugin, "%.vim", ""))
      if loaded then
        print("Found plugin: " .. plugin)
      end
    end
  end, {})

  -- 4. Add a command to apply a more aggressive fix if needed
  vim.api.nvim_create_user_command("ApplyAggressiveFix", function()
    -- This is a more aggressive approach that may help in difficult cases
    -- It adds a special variable that tells Neovim to avoid re-mapping keys
    vim.g.fix_key_repeat = true

    -- Use raw mode for insert mode to bypass potential remapping systems
    vim.api.nvim_set_keymap('i', '<CR>', '<CR>', { noremap = true, silent = true, nowait = true })
    vim.api.nvim_set_keymap('i', '<BS>', '<BS>', { noremap = true, silent = true, nowait = true })

    -- Try to ensure key events are processed only once
    vim.api.nvim_create_autocmd({ "InsertEnter" }, {
      callback = function()
        vim.opt.timeout = true
        vim.opt.ttimeout = true
        vim.opt.timeoutlen = 500
        vim.opt.ttimeoutlen = 10
      end
    })

    print("Applied aggressive fix for key repeat issues")
  end, {})

  -- Print success message
  print("Applied basic fixes for double key presses. Run :DiagnoseKeyIssues for more info.")
  print("If issues persist, run :ApplyAggressiveFix for a more aggressive approach.")
end

-- Run the fix
fix_double_key_presses()
