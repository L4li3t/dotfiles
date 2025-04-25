-- lua/plugins/ui.lua OR lua/plugins/utils.lua

return {
  { "nvimdev/dashboard-nvim",
  event = "VimEnter", -- Load when Neovim has fully entered and is ready
  dependencies = {
    -- Needs icons
    "nvim-tree/nvim-web-devicons",
    -- Optional: telescope for session browsing action
    "nvim-telescope/telescope.nvim"
  },
  config = function()
    -- Check if we should enter the dashboard
    local function should_dashboard()
      -- Check if arguments were passed when starting Neovim
      if vim.fn.argc() > 0 then
        return false
      end

      -- Check if we are reading from stdin
      if not vim.fn.empty(vim.fn.getline(1)) and vim.fn.line('$') > 1 then
         return false
      end

      -- Check the buffer type and name
      local buftype = vim.api.nvim_buf_get_option(0, 'buftype')
      local bufname = vim.api.nvim_buf_get_name(0)
      if bufname ~= '' and bufname ~= '[No Name]' then
        return false
      end
      if buftype ~= '' and buftype ~= 'nofile' then
        return false
      end

      -- If all checks pass, show the dashboard
      return true
    end

    if not should_dashboard() then
      return
    end

    -- Dashboard setup can proceed
    local db = require("dashboard")
    local utils = {} -- Helper functions namespace

    -- Function to open Neovim config directory/file
    function utils.open_config()
      local config_dir_raw = vim.fn.expand("$LOCALAPPDATA/nvim")
      -- Normalize path separators for cross-platform safety (though $LOCALAPPDATA is Windows specific)
      local config_dir = config_dir_raw:gsub("\\", "/")
      local init_path = config_dir .. "/init.lua"

      -- Check if init.lua exists
      local init_stat = vim.loop.fs_stat(init_path)

      -- Prefer opening init.lua, otherwise open the config directory itself
      if init_stat and init_stat.type == "file" then
        vim.cmd("edit " .. vim.fn.fnameescape(init_path))
      elseif vim.fn.isdirectory(config_dir) == 1 then
        -- Use Telescope or NvimTree to browse the config directory if preferred
        -- Option 1: Use Telescope
        require('telescope.builtin').find_files({ cwd = config_dir })
        -- Option 2: Use NvimTree (if installed)
        -- vim.cmd("NvimTreeFindFile " .. vim.fn.fnameescape(config_dir))
        -- Option 3: Simple edit command (might open netrw or nvim-tree depending on hijack settings)
        -- vim.cmd("edit " .. vim.fn.fnameescape(config_dir))
      else
        vim.notify("Neovim config directory not found at: " .. config_dir, vim.log.levels.ERROR)
      end
    end

    -- Hydra-like ASCII Logo (Customize as you like!)
    -- Source/Inspiration: Could search for "ascii art hydra", "ascii art octopus", or geometric patterns
    db.custom_header = {
      "                                                 ",
      "           .--.                                  ",
      "          /    \\         NVIM                     ",
      "         |  ><  |                                 ",
      "       /| ~~~~ |\\                              ",
      "      / | \\__/ | \\       Version: ".. vim.version().major.."."..vim.version().minor.."."..vim.version().patch,
      "     / /|  /\\  |\\ \\                            ",
      "    / / | /  \\ | \\ \\                           ",
      "   / /  \\ `..' /  \\ \\                          ",
      "  / /    '.}/.'    \\ \\                         ",
      " | |     /||\\     | |                          ",
      "  \\ \\   //||\\\\   / /                          ",
      "   \\ \\ ///||\\\\\\ / /                           ",
      "    `--\\\\\\||//////--'                            ",
      "        `------'                                 ",
      "                                                 ",
    }

    -- Define the buttons/actions in the center
    db.custom_center = {
      -- Recent Files (Uses Telescope Oldfiles)
      { icon = " ", desc = "Recent Files        ", action = "Telescope oldfiles", key = "r" },

      -- Load Last Session (integrates with persistence.nvim)
      { icon = " ", desc = "Load Last Session   ", action = function()
          local ok, ps = pcall(require, "persistence")
          if ok then
            local loaded = ps.load({ last = true }) -- Try loading last session for current dir
            if not loaded then
                 vim.notify("No session found for current directory.", vim.log.levels.INFO)
            end
          else
            vim.notify("persistence.nvim not available.", vim.log.levels.WARN)
          end
        end, key = "s" },

      -- Find Files (Uses Telescope)
      { icon = " ", desc = "Find Files          ", action = "Telescope find_files", key = "f" },

      -- Edit Neovim Config
      { icon = " ", desc = "Neovim Config       ", action = utils.open_config, key = "c" },

      -- Open Lazy UI
      { icon = "󰅚 ", desc = "Lazy Manager        ", action = "Lazy", key = "l" },

      -- Quit Neovim
      { icon = " ", desc = "Quit NVIM           ", action = "qa", key = "q" },
    }

    -- Optional: Add a footer
    db.custom_footer = {
      "",
      "~ Ready to craft some code? ~",
    }

    -- Setup dashboard with custom sections
    db.setup({
      theme = "doom", -- Popular themes: 'hyper', 'doom', 'default', 'minimal'
      config = {
        header = db.custom_header,
        center = db.custom_center,
        footer = db.custom_footer,
        -- How shortcuts are displayed: 'letter', 'number', 'icon'
        shortcut_type = "letter",
        -- Show week header (optional)
        week_header = {
          enable = true,
        },
        -- Hide statusline, tabline etc. on dashboard (optional)
        hide = {
           statusline = true, -- Set to true to hide statusline
        }
      },
    })

  end,
 },
{
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {},
},
}
