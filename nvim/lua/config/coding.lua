-- lua/plugins/lsp.lua
-- Defines LSP, Mason, Completion, and related plugins
-- Each plugin is defined separately, avoiding the 'dependencies' key.

return {

  -- ==============
  -- === Mason: LSP/DAP/Linter/Formatter Installer ===
  -- ==============
  {
    "williamboman/mason.nvim",
    cmd = "Mason", -- Load when running :Mason
    opts = {
      -- Optionally configure Mason defaults here
      -- ui = { border = "rounded" },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      -- Optional: Add a command to update everything
      vim.api.nvim_create_user_command("MasonUpdate", function()
        require("mason").update()
      end, { desc = "Update all Mason packages" })
    end,
  },

  -- ==============
  -- === Mason-LSPConfig: Bridge between Mason and LSPConfig ===
  -- ==============
  {
    "williamboman/mason-lspconfig.nvim",
    -- No explicit dependency, but needs mason.nvim and nvim-lspconfig.
    -- It's typically called by nvim-lspconfig's config, so load it reasonably early.
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- List of servers Mason should ensure are installed
      ensure_installed = {
        -- "tsserver", -- TypeScript/JavaScript/React/JSX/TSX (handled in lspconfig setup)
        "html",        -- HTML
        "cssls",       -- CSS/SCSS/Less
        "jsonls",      -- JSON
        "marksman",    -- Markdown
        "emmet_ls",    -- Emmet support for HTML/CSS/JSX/etc.
        "tailwindcss", -- Tailwind CSS IntelliSense
        'lua_ls',      -- For Lua development
        'biome'
        -- 'bashls', -- For Bash scripts
        -- 'dockerls', -- For Dockerfiles
        -- 'yamlls', -- For YAML
        -- 'pyright', -- For Python
      },
      -- Whether to automatically install missing servers (usually false, handled by ensure_installed)
      -- automatic_installation = false,
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
      -- NOTE: The actual setup of LSP servers using mason-lspconfig happens
      -- within the nvim-lspconfig config function below.
    end,
  },

  -- ==============
  -- === LSP Configuration ===
  -- ==============
  {
    "neovim/nvim-lspconfig",
    -- This plugin's config will require mason-lspconfig and cmp_nvim_lsp,
    -- so lazy.nvim should load them first.
    event = { "BufReadPre", "BufNewFile" }, -- Load LSP config when opening files
    config = function()
      -- Setup language servers.
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig") -- Should be loaded before this config runs
      local cmp_nvim_lsp = require("cmp_nvim_lsp")       -- Should be loaded before this config runs

      -- Keymaps (global, diagnostic-related)
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
      vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic hover" })
      vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list (Location List)" })

      -- Configure diagnostic signs
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" }) -- Use "" for numhl to avoid highlighting number column
      end

      vim.diagnostic.config({
        virtual_text = true, -- Show diagnostics inline
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- LSP handlers (customize display of hover/signatureHelp)
      local handlers = {
          ["textDocument/hover"] = function(_, result, ctx, config)
            config = config or {}
            config.border = "rounded"
            return vim.lsp.handlers.hover(_, result, ctx, config)
          end,
          ["textDocument/signatureHelp"] = function(_, result, ctx, config)
            config = config or {}
            config.border = "rounded"
            return vim.lsp.handlers.signature_help(_, result, ctx, config)
          end,
      }

      -- Default on_attach function (runs per-server)
      local on_attach = function(client, bufnr)
        local nmap = function(keys, func, desc)
          if desc then desc = "LSP: " .. desc end
          vim.keymap.set("n", keys, func, { buffer = bufnr, noremap = true, silent = true, desc = desc })
        end

        -- Keybinds specific to LSP features
        nmap("<leader>rn", vim.lsp.buf.rename, "Rename")
        nmap("<leader>ca", vim.lsp.buf.code_action, "Code Action")
        nmap("gd", require("telescope.builtin").lsp_definitions, "Go to Definition")
        nmap("gr", require("telescope.builtin").lsp_references, "Go to References")
        nmap("gI", require("telescope.builtin").lsp_implementations, "Go to Implementation")
        nmap("<leader>D", vim.lsp.buf.type_definition, "Type Definition")
        nmap("K", vim.lsp.buf.hover, "Hover Documentation")
        nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Help")
        nmap("gD", vim.lsp.buf.declaration, "Go to Declaration")
        nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder")
        nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")
        nmap("<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
          "List Workspace Folders")

        -- Formatting command/keymap
        if client.supports_method("textDocument/formatting") then
          nmap("<leader>ù", function() vim.lsp.buf.format({ async = true }) end, "Format Buffer")
          vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
            vim.lsp.buf.format({ async = true })
          end, { desc = "Format current buffer with LSP" })
        end

        -- Add other capabilities or checks here if needed
      end

      -- Default capabilities provided by nvim-cmp
      local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

      -- === Setup LSP servers using mason-lspconfig ===
      -- This relies on the list set in mason-lspconfig.nvim's opts
      mason_lspconfig.setup_handlers({
        -- Default handler: Sets up servers with common settings
        function(server_name)
          lspconfig[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
            handlers = handlers,
          })
        end,

        -- === Custom server configurations ===
        ["denols"] = function()
                  lspconfig.denols.setup({
          on_attach = on_attach,          -- Use your existing on_attach function
          capabilities = capabilities,      -- Use your existing capabilities table
          root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc", ".git"), -- Detect Deno project root
          settings = {
            deno = {
              enable = true,             -- Enable Deno specific features
              lint = true,               -- Enable Deno linting
              unstable = false,          -- Set to true if you use unstable Deno APIs
              -- Inlay Hints settings mapped from your tsserver config
              inlayHints = {
                parameterNames = {
                  enabled = "all",       -- Corresponds to: includeInlayParameterNameHints = "all"
                  -- Note the logic inversion: 'suppress' vs 'include when not matching'
                  suppressWhenArgumentMatchesName = true, -- Corresponds to: includeInlayParameterNameHintsWhenArgumentMatchesName = false
                },
                parameterTypes = {
                  enabled = true,        -- Corresponds to: includeInlayFunctionParameterTypeHints = true
                },
                variableTypes = {
                  enabled = true,        -- Corresponds to: includeInlayVariableTypeHints = true
                },
                propertyDeclarationTypes = {
                  enabled = true,        -- Corresponds to: includeInlayPropertyDeclarationTypeHints = true
                },
                functionLikeReturnTypes = {
                  enabled = true,        -- Corresponds to: includeInlayFunctionLikeReturnTypeHints = true
                },
                enumMemberValues = {
                  enabled = true,        -- Corresponds to: includeInlayEnumMemberValueHints = true
                },
              }
            }
          },
          -- Specify filetypes for Deno LSP
          filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "json", "jsonc", "markdown" }
        })
        end,
        ["ts_ls"] = function() -- Example: Custom setup for tsserver
          lspconfig.ts_ls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            handlers = handlers,
            settings = { -- Specific settings for tsserver
              typescript = { inlayHints = { includeInlayParameterNameHints = "all", includeInlayParameterNameHintsWhenArgumentMatchesName = false, includeInlayFunctionParameterTypeHints = true, includeInlayVariableTypeHints = true, includeInlayPropertyDeclarationTypeHints = true, includeInlayFunctionLikeReturnTypeHints = true, includeInlayEnumMemberValueHints = true, }, },
              javascript = { inlayHints = { includeInlayParameterNameHints = "all", includeInlayParameterNameHintsWhenArgumentMatchesName = false, includeInlayFunctionParameterTypeHints = true, includeInlayVariableTypeHints = true, includeInlayPropertyDeclarationTypeHints = true, includeInlayFunctionLikeReturnTypeHints = true, includeInlayEnumMemberValueHints = true, }, },
            },
          })
        end,
        ["html"] = function()
          lspconfig.html.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            handlers = handlers,
            filetypes = { "html", "htmldjango", "jinja.html", "php" },
            init_options = { configurationSection = { "html", "css", "javascript" }, embeddedLanguages = { css = true, javascript = true }, provideFormatter = true, },
            -- Example for HTMX attributes (ensure htmx.org is in node_modules or adjust path)
            -- settings = { ["html.experimental.customData"] = { "node_modules/htmx.org/custom-elements.html-data.json" } }
          })
        end,
        ["tailwindcss"] = function()
          lspconfig.tailwindcss.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            handlers = handlers,
            filetypes = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte", "astro", "elixir", "eelixir", "heex", "eruby", "templ" }, -- Added templ
            init_options = { userLanguages = { eelixir = "html-eex", heex = "html-eex", templ = "html" } },                                                                           -- Added templ mapping
            settings = {
              tailwindCSS = {
                experimental = { classRegex = { { "\\b(c|C)lass(Name)?\\s*=\\s*\"([^\"]*)\"", "'([^']*)'" }, { "\\b(c|C)lass(Name)?\\s*=\\s*{`([^`]*)}`", "'([^']*)'" } } },
                includeLanguages = { eelixir = "html", heex = "html", templ = "html" },
                validate = true,
              }
            },
          })
        end,
        ["emmet_ls"] = function()
          lspconfig.emmet_ls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            handlers = handlers,
            filetypes = { "html", "css", "scss", "less", "sass", "javascriptreact", "typescriptreact", "haml", "xml", "xsl", "pug", "slim", "jsx", "tsx", "templ" }, -- Added templ
          })
        end,
        ["lua_ls"] = function() -- Setup for Lua Language Server
          lspconfig.lua_ls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            handlers = handlers,
            settings = {
              Lua = {
                runtime = { version = 'LuaJIT' },                                   -- Use LuaJIT runtime analysis
                diagnostics = { globals = { 'vim' } },                              -- Recognize 'vim' global
                workspace = { library = vim.api.nvim_get_runtime_file("", true) },  -- Include Neovim runtime path
                telemetry = { enable = false },
              },
            },
          })
        end,
        ["biome"] = function()
          lspconfig.biome.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            handlers = handlers,
            cmd = { "biome", "lsp-proxy" }, -- This is crucial
            filetypes = { "javascript", "javascriptreact", "json", "jsonc", "typescript", "typescriptreact" },
            root_dir = lspconfig.util.root_pattern("biome.json", "biome.jsonc"),
          })
        end,        -- Add other custom server setups here...
      })
    end,
  },

  -- ==============
  -- === LSP UI Helpers ===
  -- ==============
  {
    "j-hui/fidget.nvim",
    -- Fidget provides status updates for LSP initialization/progress.
    -- Load when LSP attaches or very lazily.
    event = "LspAttach",
    opts = {
      -- Configuration options for fidget
      notification = { window = { winblend = 0 } },
      -- progress = { display = { ... } }
    },
    -- config is optional if opts is enough, but fine to keep
    config = function(_, opts)
      require("fidget").setup(opts)
    end
  },
  {
    "b0o/schemastore.nvim",
    -- Provides JSON schemas, useful for jsonls.
    lazy = true, -- Load very late, only needed by jsonls potentially
  },

  -- ==============
  -- === Autocompletion Engine (nvim-cmp) ===
  -- ==============
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter", -- Load when entering insert mode
    -- nvim-cmp's config will require its sources, so lazy.nvim should load them.
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip") -- Will load LuaSnip plugin
      local lspkind = require("lspkind") -- Will load lspkind plugin

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion = cmp.config.window.bordered({ border = "rounded" }),
          documentation = cmp.config.window.bordered({ border = "rounded" }),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        -- Define completion sources. These plugins must be loaded.
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- Source for LSP completions
          { name = "luasnip" },  -- Source for snippets
          { name = "buffer" },   -- Source for words from current buffer
          { name = "path" },     -- Source for file system paths
        }),
        formatting = {
          format = lspkind.cmp_format({ -- Use lspkind for icons
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
            -- Optional: Show source name
            -- before = function (entry, vim_item)
            --   vim_item.menu = "["..string.upper(entry.source.name).."]"
            --   return vim_item
            -- end
          }),
        },
      })
    end,
  },

  -- ==============
  -- === Snippet Engine (LuaSnip) ===
  -- ==============


  {
    "L3MON4D3/LuaSnip",
    -- Load alongside nvim-cmp or slightly before
    event = "InsertEnter",
    -- If you have issues, uncommenting the version might help lock it
    -- version = "v2.*",
    -- Build step for potential JS regex engine (improves performance)
    build = "make install_jsregexp",
    config = function()
      -- Basic LuaSnip setup
      require("luasnip").setup({})
      -- Load snippets from friendly-snippets (requires friendly-snippets to be loaded)
      require("luasnip.loaders.from_vscode").lazy_load()
      -- Optional: Load snippets from other locations
      -- require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/snippets"})
    end,
  },

  -- ==============
  -- === Snippet Collection ===
  -- ==============
  {
    "rafamadriz/friendly-snippets",
    -- No config needed, LuaSnip just needs this to be present
    lazy = true, -- Load when LuaSnip needs it (implicitly)
  },
  {
    "saadparwaiz1/cmp_luasnip",
    -- Load it when cmp loads, typically on InsertEnter
    event = "InsertEnter",
    -- No specific config usually needed here, it just needs to be loaded
  },
  -- ==============
  -- === CMP Sources & Helpers ===
  -- ==============
  { "saadparwaiz1/cmp_luasnip", event = "InsertEnter" }, -- Bridge between cmp and luasnip
  { "hrsh7th/cmp-nvim-lsp",     event = "InsertEnter" }, -- LSP completion source for cmp
  { "hrsh7th/cmp-buffer",       event = "InsertEnter" }, -- Buffer completion source for cmp
  { "hrsh7th/cmp-path",         event = "InsertEnter" }, -- Path completion source for cmp
  {
    "onsails/lspkind.nvim",                              -- Adds icons to completion items
    event = "InsertEnter",                               -- Load when cmp loads
    config = function()
      -- Optional: You can set options for lspkind here if needed
      require("lspkind").setup({
        -- mode = 'symbol_text', -- Moved to cmp formatting section
        -- preset = 'codicons',
        -- symbol_map = { ... }
      })
    end
  },

  -- ==============
  -- === Optional: Signature Help ===
  -- ==============
  {
    "ray-x/lsp_signature.nvim",
    -- Load when LSP attaches or VeryLazy, as it's a UI enhancement
    event = "LspAttach",
    opts = {
      bind = true, -- This is Behavior Binding
      doc_lines = 0,
      floating_window = true,
      fix_pos = true,
      hint_enable = true,
      hint_prefix = "👈 ",
      hint_scheme = "String",
      hi_parameter = "LspSignatureActiveParameter",
      max_height = 12,
      max_width = 120,
      handler_opts = { border = "rounded" },
      padding = '',
    },
    -- Using opts is generally sufficient, config is redundant if just calling setup(opts)
    -- config = function(_, opts)
    --   require("lsp_signature").setup(opts)
    -- end,
  },
  {
    --'mfussenegger/nvim-dap',
    'sigmaSd/deno-nvim',
    config = function ()
      require('deno-nvim').setup({
        --[[ server = { ]]
        --[[   on_attach = ..., ]]
        --[[   capabilities = ... ]]
        --[[ } ]]
      })
    end
  }
  --[[ { ]]
  --[[   'nvim-lua/lsp-status.nvim', ]]
  --[[    event = "VeryLazy" ]]
  --[[ }, ]]

} -- End of LSP plugin list-- End of LSP plugin list
