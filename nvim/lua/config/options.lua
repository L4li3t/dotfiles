---------Globals vim.g-------
local g = vim.g

g.mapleader = " "
g.maplocalleader = "ù"

--------Options------------------

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.autowrite = true --this enables nvim to save buffer when quitting even without saving manually
opt.clipboard = "unnamedplus" --this syncs the systems clipboard with nvim
opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
opt.completeopt = "menu,menuone,noselect" --
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.expandtab = true -- Use spaces instead of tabs
opt.shell = "zsh"
opt.fillchars = {
	foldopen = "",
	foldclose = "",
	fold = " ",
	foldsep = " ",
	diff = "╱",
	eob = " ",
}
opt.foldlevel = 99
opt.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()"
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true -- Ignore case
opt.inccommand = "nosplit" -- preview incremental substitute
opt.jumpoptions = "view"
opt.laststatus = 3 -- global statusline
opt.linebreak = true -- Wrap lines at convenient points
opt.list = true -- Show some invisible characters (tabs...
opt.mouse = "a" -- Enable mouse mode
-- opt.number = true -- Print line number
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
-- opt.relativenumber = true -- Relative line numbers
opt.ruler = false -- Disable the default ruler
opt.scrolloff = 4 -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
-- opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false -- Dont show mode since we have a statusline
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.spelllang = { "en" }
opt.splitbelow = true -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows right of current
opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
opt.tabstop = 2 -- Number of spaces tabs count for
opt.termguicolors = true -- True color support
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- Lower than default (1000) to quickly trigger which-key
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap
vim.opt.shellcmdflag = "-c"
--[[ opt.background = "light" ]]
vim.o.background = "light"

---- move arround windows using ctrl jklh ---------------
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

------------remapping hjlk for faster movement ---------------
---
---
-- Remap d and f for navigation
vim.keymap.set('n', 'd', 'h', { noremap = true, silent = true, desc = "Move left" })
vim.keymap.set('n', 'f', 'l', { noremap = true, silent = true, desc = "Move right" })
vim.keymap.set('v', 'd', 'h', { noremap = true, silent = true, desc = "Move selection left" })
vim.keymap.set('v', 'f', 'l', { noremap = true, silent = true, desc = "Move selection right" })
vim.keymap.set('o', 'd', 'h', { noremap = true, silent = true, desc = "Operator-pending move left" })
vim.keymap.set('o', 'f', 'l', { noremap = true, silent = true, desc = "Operator-pending move right" })

-- Remap h and l to original d and f actions
vim.keymap.set('n', 'h', 'd', { noremap = true, silent = true, desc = "Original d (delete/operator)" })
vim.keymap.set('n', 'l', 'f', { noremap = true, silent = true, desc = "Original f (find character forward)" })
vim.keymap.set('v', 'h', 'd', { noremap = true, silent = true, desc = "Original d (delete selection)" })
vim.keymap.set('v', 'l', 'f', { noremap = true, silent = true, desc = "Original f (find char in visual - less common)" })
vim.keymap.set('o', 'h', 'd', { noremap = true, silent = true, desc = "Original d (operator-pending motion, e.g., dh -> dd)" })
vim.keymap.set('o', 'l', 'f', { noremap = true, silent = true, desc = "Original f (operator-pending motion)" })

----------terminal settings ---------


-- Put this in your Neovim configuration (e.g., init.lua or a dedicated setup file)

-- 1. Autocommand to automatically enter insert mode when a terminal opens
vim.api.nvim_create_augroup("UserTermConfig", { clear = true }) -- Create a group (clears previous definitions on reload)
vim.api.nvim_create_autocmd("TermOpen", {
  group = "UserTermConfig",
  pattern = "*", -- Apply to all terminal buffers
  command = "startinsert", -- Execute the Neovim command after terminal opens
  -- Alternatively, use Lua:
  -- callback = function()
  --   vim.cmd("startinsert")
  -- end,
})

-- 2. Functions to open terminals (now simplified)
local function open_vsplit_terminal()
  -- Just open the terminal; the autocmd will handle startinsert
  vim.cmd('vsp | terminal')
end

local function open_hsplit_terminal()
  -- Just open the terminal; the autocmd will handle startinsert
  vim.cmd('sp | terminal')
end
--3. autoclose when typing "close"
vim.api.nvim_create_autocmd("TermClose", {
  group = "UserTermConfig",
  pattern = "*", -- Apply to all closing terminal buffers
  command = "close", -- Close the window containing the buffer
  -- Explanation:
  -- 'close' is generally safer than 'quit' or 'bdelete'.
  -- It closes the window. If it's the last window, Neovim stays open.
  -- If you wanted to force buffer deletion even if window isn't found,
  -- you might use a Lua callback, but 'close' handles the common case.
})
-- 4. Keymaps (remain the same)
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 5. NEW: Autocommand to automatically enter insert mode when ENTERING a terminal window
vim.api.nvim_create_autocmd("WinEnter", {
  group = "UserTermConfig",
  pattern = "*", -- Check on entering ANY window
  callback = function()
    -- Check if the buffer in the window we just entered is a terminal
    local buftype = vim.api.nvim_buf_get_option(0, 'buftype') -- 0 means current buffer
    if buftype == 'terminal' then
      -- If it's a terminal, enter Terminal-Normal mode (like insert)
      vim.cmd("startinsert")
    end
  end,
})


map('n', '<leader>tv', open_vsplit_terminal, { desc = "Terminal: Open Vertical Split", silent = true })
map('n', '<leader>th', open_hsplit_terminal, { desc = "Terminal: Open Horizontal Split", silent = true })

-- 4. ESSENTIAL: Keymap to exit Terminal mode (remain the same)
map('t', '<esc>', '<C-\\><C-n>', { desc = "Terminal: Exit to Normal Mode", silent = true })

map('t', '<C-h>', '<C-\\><C-n><C-w>h', { desc = "Window: Navigate Left", silent = true })
map('t', '<C-j>', '<C-\\><C-n><C-w>j', { desc = "Window: Navigate Down", silent = true })
map('t', '<C-k>', '<C-\\><C-n><C-w>k', { desc = "Window: Navigate Up", silent = true })
map('t', '<C-l>', '<C-\\><C-n><C-w>l', { desc = "Window: Navigate Right", silent = true })
---------- end of Terminal setup ------------------------------
