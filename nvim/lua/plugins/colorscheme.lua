return {
    ------   STATUS LINE   -----------------
    {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      --event = "VeryLazy",
      --priority = 1000,
      --[[ config = function () ]]
      --[[   require('lualine').setup({}) ]]
      --[[ end ]]
    },
    {
    "famiu/feline.nvim",
    priority = 1000,
    config = function ()
      local dawn = {
        fg = '#D0D0D0',
        bg = '#1F1F23',
        black = '#1B1B1B',
        skyblue = '#50B0F0',
        cyan = '#009090',
        green = '#60A040',
        oceanblue = '#0066cc',
        magenta = '#C26BDB',
        orange = '#FF9000',
        red = '#D10000',
        violet = '#9E93E8',
        white = '#FFFFFF',
        yellow = '#E1E120',
        }
      require('feline').add_theme('dawn', dawn)
      require('feline').use_theme(dawn)
      require('feline').setup()
    end,
  },





-------  COLORSCHEMES -----------





  {
    "franbach/miramare",
    --priority = 1000,
    lazy = "true"
    --config = function()
    --	vim.cmd[[colorscheme miramare]]
    --end,
  },

  {
    "bluz71/vim-moonfly-colors",
    name = "moonfly",
    lazy = true,
    --priority = 1000,
    config = function()
      require("moonfly").custom_colors({
        bg = '#161616',
        violet = '#ff74b8',
      })
      --vim.cmd[[colorscheme moonfly]]
    end
  },

  {
    "sainnhe/sonokai",
    lazy = true,    -- Recommended, load theme early
    --priority = 1000, -- Recommended, make sure it loads before other plugins start customizing colors
    config = function()
      -- Optional: Set style variant here BEFORE setting colorscheme
      vim.g.sonokai_style = 'maia'    -- Options: default, atlantis, andromeda, shusia, maia, espresso
      -- vim.g.sonokai_enable_italic = 1 -- Enable italic comments/keywords
      -- vim.g.sonokai_disable_background = 1 -- Enable transparent background

      -- Load the colorscheme
      -- vim.cmd("colorscheme sonokai")
    end,
  },

  {
    "sainnhe/everforest",
    lazy =true,    -- Recommended, load theme early
    --priority = 1000, -- Recommended, make sure it loads before other plugins start customizing colors
    config = function()
      -- Optional: Set configuration variables here BEFORE setting the colorscheme
      vim.g.everforest_background = 'medium'    -- Options: 'soft', 'medium', 'hard' (default medium)
      -- vim.g.everforest_enable_italic = 1    -- Enable italic comments/keywords
      -- vim.g.everforest_transparent_background = 1 -- Enable transparent background

      -- Load the colorscheme
--      vim.cmd("colorscheme everforest")
    end,
  },
  --------statusline setup ------------------
  --[[ { ]]
  --[[   'itchyny/lightline.vim', ]]
  --[[   event = 'VeryLazy', ]]
  --[[   config = function() ]]
  --[[     vim.g.lighline = 'everforest' ]]
  --[[   end ]]
  --[[ }, ]]
  {
  'b0o/incline.nvim',
   event = 'BufRead',
   config = function()
     local helpers = require 'incline.helpers'
     local devicons = require 'nvim-web-devicons'
     require('incline').setup {
       window = {
         padding = 0,
         margin = { horizontal = 3 , vertical = 1},
       },
       render = function(props)
         local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
         if filename == '' then
           filename = '[No Name]'
         end
         local ft_icon, ft_color = devicons.get_icon_color(filename)
         local modified = vim.bo[props.buf].modified
         return {
           ft_icon and { ' ', ft_icon, ' ', guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or '',
           ' ',
           { filename, gui = modified and 'bold,italic' or 'bold' },
           ' ',
           guibg = '#ECE8DD',
         }
        end,
       }
    end,
    },
    
    {
  	"metalelf0/black-metal-theme-neovim",
  	lazy = true,
  	-- priority = 1000,
  	--[[ config = function() ]]
  --[[ 	  require("black-metal").setup({ ]]
		--[[ theme = "emperor", ]]
  --[[   variant = "light" ]]
  --[[ 	  }) ]]
  --[[ 	  require("black-metal").load() ]]
  --[[ 	end, ]]
    },
    {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    config = function ()
      require("nightfox").setup({})
      --[[ vim.cmd("colorscheme dayfox") ]]
    end
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    config = function ()
      vim.cmd("colorscheme rose-pine")
    end
  },
}
