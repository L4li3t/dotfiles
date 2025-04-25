-- lua/plugins/ui.lua
-- Contains plugins related to User Interface elements like file explorer,
-- fuzzy finder, icons, persistence, which-key etc.

return {

  -- ==============
  -- === File Explorer ===
  -- ==============
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- Required for icons
    cmd = "NvimTreeToggle",                           -- Load when the command is triggered
    keys = {
      { "<leader><leader>", "<cmd>NvimTreeToggle<CR>",   desc = "Explorer (NvimTree)" },
      { "<leader>o", "<cmd>NvimTreeFindFile<CR>", desc = "Explorer Find File (NvimTree)" },
    },
    opts = {
      -- General options
      sort_by = "name",
      auto_reload_on_write = true,
      disable_netrw = true, -- Recommended: Disable netrw
      hijack_netrw = true,  -- Recommended: Use nvim-tree for directory opening
      hijack_cursor = false,
      hijack_unnamed_buffer_when_opening = false,
      sync_root_with_cwd = true, -- Keep tree root synced with CWD
      update_focused_file = {
        enable = true,
        update_root = true, -- Change tree root when CWD changes
      },
      -- View options
      view = {
        width = 30,
        side = "left",
        -- adaptive_size = true, -- Uncomment for adaptive sizing
        number = false,
        relativenumber = false,
        signcolumn = "yes", -- Show git signs in nvim-tree
      },
      -- Git integration options
      git = {
        enable = true,
        ignore = false,
        timeout = 400,
      },
      -- Filtering options
      filters = {
        dotfiles = false,                              -- Show dotfiles
        custom = { ".git", "node_modules", ".cache" }, -- Hide specific folders/files
        exclude = {},
      },
      -- Renderer options (icons, etc.)
      renderer = {
        group_empty = true,              -- Show empty folders
        highlight_git = true,
        highlight_opened_files = "none", -- Options: name, icon, all, none
        indent_markers = {
          enable = true,                 -- Show indent markers
        },
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
          glyphs = {
            default = "󰈚", -- Default file icon
            symlink = "",
            folder = {
              arrow_closed = "",
              arrow_open = "",
              default = "", -- Default folder icon
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
              symlink_open = "",
            },
            git = {
              unstaged = "✗",
              staged = "✓",
              unmerged = "",
              renamed = "➜",
              untracked = "★",
              deleted = "🗑",
              ignored = "◌",
            },
          },
        },
      },
      -- Actions options (opening files, etc.)
      actions = {
        open_file = {
          quit_on_open = false, -- Keep nvim-tree open when opening a file
          resize_window = true, -- Resize window when opening a file
          window_picker = {
            enable = true,
            chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
            exclude = {
              filetype = { "notify", "lazy", "qf", "diff", "fugitive", "fugitiveblame" },
              buftype = { "nofile", "terminal", "help" },
            },
          },
        },
      },
      -- Trash integration (optional, requires 'trash-cli')
      -- trash = {
      --   cmd = "trash",
      --   require_confirm = true,
      -- },
      -- Diagnostics integration (optional)
      diagnostics = {
        enable = true,
        show_on_dirs = true, -- Show diagnostics on folders
        icons = {
          hint = "",
          info = "",
          warning = "",
          error = "",
        },
      },
    },
    -- No config needed here, lazy.nvim handles passing opts to setup
  },

  -- ==============
  -- === Icons === (Dependency for nvim-tree and telescope)
  -- ==============
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,      -- Load when needed by other plugins
    opts = {
      default = true, -- Setup with default icons
    },
    -- No config needed here, lazy.nvim handles passing opts to setup
  },

  -- ==============
  -- === Fuzzy Finder ===
  -- ==============
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope", -- Load when command is triggered
    keys = {
      -- Define your keymaps here (copied from your original file)
      { "<leader>ff", "<cmd>Telescope find_files<cr>",             desc = "Find Files" },
      { "<leader>fa", "<cmd>Telescope find_files hidden=true<cr>", desc = "Find All Files (Hidden)" },
      { "<leader>gf", "<cmd>Telescope git_files<cr>",              desc = "Find Git Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",              desc = "Live Grep" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>",            desc = "Word Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",                desc = "Find Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",              desc = "Help Tags" },
      { "<leader>fc", "<cmd>Telescope commands<cr>",               desc = "Commands" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>",            desc = "Diagnostics" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>",            desc = "Git Commits" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>",             desc = "Git Status" },
      { "<leader>fr", "<cmd>Telescope resume<cr>",                 desc = "Resume Search" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",           -- Required dependency
      { "nvim-tree/nvim-web-devicons" }, -- Optional: Better icons if available
      -- Optional: Faster C implementation of fuzzy matching
      -- { "nvim-telescope/telescope-fzf-native.nvim", build = "make", config = function() require('telescope').load_extension('fzf') end },
    },
    -- Use config for more complex setup involving local variables or loading extensions
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55, results_width = 0.8 },
            vertical = { mirror = false },
            flex = { horizontal = { prompt_position = "top", preview_width = 0.6 } },
            width = 0.85,
            height = 0.80,
            preview_cutoff = 120,
          },
          sorting_strategy = "ascending",
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case",
            "--hidden", "--glob=!{.git,node_modules/*}",
          },
          prompt_prefix = "  ",
          selection_caret = " ",
          entry_prefix = "  ",
          mappings = {
            i = { -- Insert mode mappings (copied from your original file)
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
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<ESC>"] = actions.close,
            },
            n = { -- Normal mode mappings (copied from your original file)
              ["<esc>"] = actions.close,
              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
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
              ["q"] = actions.close,
            },
          },
        },
        pickers = {
          buffers = {
            sort_mru = true,
            ignore_current_buffer = true,
            mappings = { i = { ["<c-d>"] = actions.delete_buffer }, n = { ["d"] = actions.delete_buffer } },
          },
          -- find_files = { find_command = { 'fd', '--type', 'f', '--hidden', '--exclude', '.git' } },
        },
        extensions = {
          -- fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = "smart_case" },
        },
      })

      -- Optional: Load extensions after setup
      -- pcall(telescope.load_extension, "fzf")
    end,
  },

  -- ==============
  -- === Keymap Helper ===
  -- ==============
  {
    "folke/which-key.nvim",
    event = "VeryLazy", -- Load late; only needed for user interaction
    opts = {
      plugins = { spelling = true },
      window = { border = "rounded" },
      -- Other which-key options can be added here
    },
    config = function(_, opts)
      vim.o.timeout = true   -- Needed for which-key mappings
      vim.o.timeoutlen = 100 -- Time in ms to wait for a mapped sequence
      require("which-key").setup(opts)
      -- Example: Register custom mappings for which-key to show
      -- require("which-key").register({
      --   ["<leader>"] = {
      --     f = { name = "[F]ind", _ = "which_key_ignore" }, -- Group definition
      --     g = { name = "[G]it", _ = "which_key_ignore" },
      --     h = { name = "[H]unk (Git)", _ = "which_key_ignore" },
      --     s = { name = "[S]ession", _ = "which_key_ignore" },
      --   },
      -- })
    end,
  },

  -- ==============
  -- === Session Management ===
  -- ==============
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- Load persists data before reading buffer
    opts = {
      dir = vim.fn.stdpath("data") .. "/sessions/",
      options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" },
      autosave = { enable = true },
      -- pre_save = function() vim.print("Saving session...") end,
      autoload = true,
      silent = false,
    },
    -- config is needed here to setup custom keymaps after the plugin setup
    config = function(_, opts)
      require("persistence").setup(opts)
      -- Optional keymaps for manual control
      vim.keymap.set("n", "<leader>ss", function() require("persistence").save() end, { desc = "Save Session Manually" })
      vim.keymap.set("n", "<leader>sl", function() require("persistence").load() end, { desc = "Load Session for CWD" })
      vim.keymap.set("n", "<leader>sd", function() require("persistence").stop() end,
        { desc = "Don't AutoSave Session on Exit" })
    end,
  },
  ------------------- faster tab navigation ---------------

  { 'ThePrimeagen/harpoon',
    event = "VeryLazy",
    config =  function ()
      require("harpoon").setup({
        menu = {
        width = vim.api.nvim_win_get_width(0) - 50,
    }})
      local mark = require("harpoon.mark")
      local ui = require("harpoon.ui")

      vim.keymap.set("n", "<leader>m", mark.add_file, {desc = "Harpoon mark file"})
      vim.keymap.set("n", "<A-e>", ui.toggle_quick_menu)

      vim.keymap.set("n", "<leader>&", function() ui.nav_file(1) end, {desc = "harpoon buff 1"})
      vim.keymap.set("n", "<leader>é", function() ui.nav_file(2) end, {desc = "harpoon buff 2"})
      vim.keymap.set("n", '<leader>"', function() ui.nav_file(3) end, {desc = "harpoon buff 3"})
      vim.keymap.set("n", "<leader>'", function() ui.nav_file(4) end, {desc = "harpoon buff 4"})
    end
  },
  {
    "norcalli/nvim-colorizer.lua",
    event = "BufEnter",
    config  = function ()
      require('colorizer').setup()
    end
  },

  -- ==============
  -- === Smooth Scrolling === (Optional)
  -- ==============
  -- {
  --  "karb94/neoscroll.nvim",
  --  event = "WinScrolled", -- Load when scrolling occurs
  --  opts = {
  --      stop_eof = true,
  --      hide_cursor = true,
  --      cursor_scrolls_alone = true,
  --  }
  --  -- No config needed if only using opts
  -- }

} -- End of ui.lua plugin list
