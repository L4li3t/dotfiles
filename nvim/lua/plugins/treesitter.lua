-- lua/plugins/treesitter.lua (or wherever you define your plugins)

return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- Recommended to use the latest stable release, but you can use 'main' for nightly features
    -- version = "*"
    event = { "BufReadPre", "BufNewFile" }, -- Load slightly later
    build = ":TSUpdate", -- Run :TSUpdate command after installation/update
    dependencies = {
      -- This dependency is automatically handled by lazy.nvim
      "nvim-treesitter/nvim-treesitter-textobjects",
      -- Optional: Add other Treesitter plugins dependencies here if needed
      -- e.g., "nvim-treesitter/nvim-treesitter-context",
    },
    config = function()
      -- Defer requiring the module until the config runs
      local treesitter_configs = require("nvim-treesitter.configs")

      treesitter_configs.setup({
        -- === Core Settings ===
        -- A list of parser names, or "all" (may be slow), or "maintained" (recommended)
        -- Add languages you frequently use.
        modules = {},
        ignore_install = {},
        ensure_installed = {
          "bash",
          "c",
          "css",
          "diff",
          "dockerfile",
          "go",
          "html",
          "javascript",
          "json",
          "lua",
          "make",
          "markdown",
          "markdown_inline", -- Required for viewing md documents diagnostics
          "query",
          "regex",
          "scss",
          "toml",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
        },

        autotag = {
          enable = true,
           enable_rename = true, -- Optional: enable auto-renaming of tags
           enable_close = true,  -- Optional: enable auto-closing of tags (default: true)
           enable_close_on_slash = true, -- Optional: enable closing tags on '/' (default: true)
          -- filetypes = { "html", "xml", ... }, -- Optional: Specify filetypes (usually auto-detected)
        },

        -- Install parsers synchronously (only applied to `ensure_installed`)
        -- Setting this to true will force Neovim to wait for parsers to install.
        -- Setting this to false is recommended for startup performance.
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        -- Requires generic C compiler / Windows compatible build toolchain
        auto_install = true,

        -- === Modules ===

        -- Highlight uses Tree-sitter syntax rules for more accurate highlighting
        highlight = {
          enable = true,
          -- Disable highlighting for very large files (optional)
          -- disable = function(lang, buf)
          --     local max_filesize = 100 * 1024 -- 100 KB
          --     local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          --     if ok and stats and stats.size > max_filesize then
          --         return true
          --     end
          -- end,

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },

        -- Indentation based on Treesitter nodes
        indent = {
          enable = true,
          -- disable = { "python" }, -- Example: disable for specific languages
        },

        -- Incremental selection based on syntax nodes (like selecting blocks)
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<c-space>", -- Start selection (or use gx/gxn in visual mode)
            node_incremental = "<c-space>", -- Increment selection
            scope_incremental = "<c-s>",   -- Increment selection based on scope
            node_decremental = "<bs>",     -- Decrement selection
          },
        },

        -- === Treesitter Textobjects Configuration ===
        -- This configures the nvim-treesitter-textobjects plugin
        -- Note: This table is passed directly to the textobjects module setup
        textobjects = {
          select = {
            enable = true,
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              -- assignments: lhs @assignment.lhs, rhs @assignment.rhs, equal @assignment.operator
              -- blocks: @block.inner, @block.outer
              -- comments: @comment.inner, @comment.outer
              -- conditionals: @conditional.inner, @conditional.outer
              -- function calls: @call.inner, @call.outer
              -- functions: @function.inner, @function.outer
              -- loops: @loop.inner, @loop.outer
              -- parameters: @parameter.inner, @parameter.outer
              -- etc. see :h treesitter-textobjects & the queries/textobjects.scm file

              -- Example keymaps:
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner", -- Select the body of a class
              ["a="] = "@assignment.outer",
              ["i="] = "@assignment.inner", -- Select inner part of an assignment
              ["al"] = "@loop.outer",
              ["il"] = "@loop.inner",
              ["ai"] = "@conditional.outer",
              ["ii"] = "@conditional.inner",
              ["a/"] = "@comment.outer", -- Does not include the comment delimiter by default
              ["i/"] = "@comment.inner", -- Select inner part of a comment
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
            -- You can choose the select mode (default is charwise 'v')
            selection_modes = {
              ['@parameter.outer'] = 'v', -- charwise
              ['@function.outer'] = 'V',  -- linewise
              ['@class.outer'] = '<c-v>', -- blockwise
            },
            -- Whether to include comments in objects (`false` by default)
            include_surrounding_whitespace = true,
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
              -- Add other moves here
              ["]a"] = "@parameter.inner",
              ["]l"] = "@loop.inner",
              ["]i"] = "@conditional.inner",
              ["]c"] = "@comment.outer",
              ["]s"] = "@statement.outer", -- Useful for moving between statements
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
              -- Add other moves here
              ["]A"] = "@parameter.inner",
              ["]L"] = "@loop.inner",
              ["]I"] = "@conditional.inner",
              ["]C"] = "@comment.outer",
              ["]S"] = "@statement.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
              -- Add other moves here
              ["[a"] = "@parameter.inner",
              ["[l"] = "@loop.inner",
              ["[i"] = "@conditional.inner",
              ["[c"] = "@comment.outer",
              ["[s"] = "@statement.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
              -- Add other moves here
              ["[A"] = "@parameter.inner",
              ["[L"] = "@loop.inner",
              ["[I"] = "@conditional.inner",
              ["[C"] = "@comment.outer",
              ["[S"] = "@statement.outer",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["<leader>a"] = "@parameter.inner", -- Swap parameters/args
              -- ["<leader>f"] = "@function.outer", -- Swap functions
            },
            swap_previous = {
              ["<leader>A"] = "@parameter.inner",
              -- ["<leader>F"] = "@function.outer",
            },
          },
        }, -- end of textobjects

        -- == Other Optional Modules ==
        -- matchup = { enable = true }, -- Highlight matching brackets, etc.
        -- context_commentstring = { enable = true, enable_autocmd = false }, -- Set commentstring based on context
        -- autotag = { enable = true }, -- Auto close/rename HTML tags
      }) -- end of setup

      -- Optional: Set keymaps for Treesitter modules if not using default or incremental selection keys
      -- vim.api.nvim_set_keymap('n', '<leader>th', ':TSHighlightCapturesUnderCursor<CR>', { noremap = true, silent = true, desc = "TS Highlight Capture" })

    end, -- end of config function
  }, -- end of nvim-treesitter plugin spec
  { 'JoosepAlviste/nvim-ts-context-commentstring'},
}
