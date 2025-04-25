-- lua/plugins/editing.lua
-- Contains plugins related to the editing experience like autopairs,
-- commenting, git signs etc.

return {

  -- ==============
  -- === Autopairs ===
  -- ==============
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter", -- Load plugin when entering insert mode
    dependencies = { "hrsh7th/nvim-cmp" }, -- Optional: explicit dependency for cmp integration
    opts = {
      check_ts = true, -- Check treesitter integration (recommended)
      ts_config = {
        lua = { "string" }, -- don't add pairs in lua string treesitter nodes
        javascript = { "template_string" }, -- don't add pairs in javscript template_string treesitter nodes
        java = false -- disable for java
      },
      -- configure map_cr = true if you want <CR> completion behavior
    },
    -- If you integrate with nvim-cmp, you might setup the cmp part here or,
    -- more commonly, within your nvim-cmp configuration itself.
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)

      -- Integrate with nvim-cmp: Check if cmp is loaded before setting up hook
      local cmp_status_ok, cmp = pcall(require, "cmp")
      if not cmp_status_ok then
        return
      end
      local cmp_autopairs_status_ok, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
      if not cmp_autopairs_status_ok then
        return
      end
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- ==============
  -- === Commenting ===
  -- ============== 

  {
    "numToStr/Comment.nvim",
    dependencies = {
      -- This is the plugin providing context-aware commentstring based on Treesitter
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    -- Load when keymap is triggered or entering specific modes
    keys = {
      { "gcc", mode = "n", desc = "Comment Toggle Current Line" },
      { "gc", mode = { "n", "v" }, desc = "Comment Toggle Linewise/Visual Selection" },
      { "gbc", mode = "n", desc = "Comment Toggle Current Block" },
      { "gb", mode = { "n", "v" }, desc = "Comment Toggle Blockwise/Visual Selection" },
    },
    opts = { -- **Make sure the pre_hook is INSIDE the opts table**
      -- Default mapping arguments
      default_mapping_opts = {
        visual = { ignore_whitespace = true },
        normal = { ignore_empty = true },
      },
      -- This pre-hook integration is the RECOMMENDED way
      ---@type fun(ctx: CommentCtx):string|nil
      pre_hook = function(ctx)
        -- Use pcall to safely require the integration, just in case
        local U = require("Comment.utils")
        local context_commentstring = require("ts_context_commentstring.internal")

        -- Determine the location override based on the context
        local location = nil
        if ctx.ctype == U.ctype.block then
          location = require("ts_context_commentstring.utils").get_cursor_location()
        elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
          location = require("ts_context_commentstring.utils").get_visual_start_location()
        end

        return context_commentstring.calculate_commentstring({
          key = ctx.ctype == U.ctype.line and "__default" or "__multiline",
          location = location,
        })
      end,

      -- You can keep other opts here if needed
    },
    config = function(_, opts)
       -- Optionally call setup if needed, but often opts is enough
       -- If using the pre_hook in opts, ensure setup doesn't overwrite it
       -- or handle the pre_hook setup logic here instead of opts.
       -- For this common integration, putting pre_hook in opts is standard.
       require("Comment").setup(opts)
    end

  },

  -- Define ts-context-commentstring explicitly if you need specific config for it,
  -- otherwise the dependency declaration above might be sufficient.
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy=true, -- Can be loaded lazily when Comment.nvim needs it
    opts = {
      -- Setting enable_autocmd = false is often recommended when using
      -- Comment.nvim's pre_hook integration to avoid conflicts.
      enable_autocmd = false,
    }
  },


  -- ==============
  -- === Git Gutter Signs ===
  -- ==============
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- Load when reading/creating buffers
    dependencies = { "nvim-lua/plenary.nvim" }, -- Implicit dependency, but good to be explicit
    opts = {
      signs = {
        add = { text = "▎" }, change = { text = "▎" }, delete = { text = "" },
        topdelete = { text = "" }, changedelete = { text = "▎" }, untracked = { text = "▎" },
      },
      signcolumn = true, numhl = false, linehl = false, word_diff = false,
      watch_gitdir = { interval = 1000, follow_files = true },
      attach_to_untracked = true,
      current_line_blame = false,
      current_line_blame_opts = { virt_text = true, virt_text_pos = "eol", delay = 500, ignore_whitespace = false },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      sign_priority = 6, update_debounce = 100, status_formatter = nil, max_file_length = 40000,
      preview_config = { border = "rounded", style = "minimal", relative = "cursor", row = 0, col = 1 },
    },
    -- Separate keys table is good practice for lazy-loading triggers
    keys = {
      { "]c", function() if vim.wo.diff then return "]c" end vim.schedule(function() require("gitsigns").next_hunk() end); return "<Ignore>" end, expr = true, desc = "Next Git Hunk" },
      { "[c", function() if vim.wo.diff then return "[c" end vim.schedule(function() require("gitsigns").prev_hunk() end); return "<Ignore>" end, expr = true, desc = "Prev Git Hunk" },
      { "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>", desc = "Stage Hunk"},
      { "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", desc = "Reset Hunk"},
      { "<leader>hu", "<cmd>Gitsigns undo_stage_hunk<CR>", desc = "Undo Stage Hunk"},
      { "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>", desc = "Preview Hunk"},
      { "<leader>hb", "<cmd>Gitsigns blame_line<CR>", desc = "Blame Line"},
      { "<leader>hB", "<cmd>Gitsigns toggle_current_line_blame<CR>", desc = "Toggle Line Blame"},
      { "<leader>hd", "<cmd>Gitsigns diffthis<CR>", desc = "Diff This"},
      { "<leader>hD", "<cmd>Gitsigns diffthis ~<CR>", desc = "Diff This ~"},
      { "<leader>ht", "<cmd>Gitsigns toggle_deleted<CR>", desc = "Toggle Deleted"},
    },
    -- No config needed here, lazy.nvim handles passing opts to setup
  },
--------Toggle term /Terminal --------------
  ---
  --look in lua/config/options.lua 

} -- End of editing.lua plugin list
