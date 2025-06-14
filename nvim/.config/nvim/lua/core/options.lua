-- vim.g.loaded_netrw = 0
-- vim.g.loaded_netrwPlugin = 0
-- vim.cmd("let g:netrw_liststyle = 3")
vim.cmd("let g:netrw_banner = 0 ")

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.showbreak = "󱞵 "

--vim.opt.swapfile = false
--vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.incsearch = true
vim.opt.inccommand = "split"

--vim.opt.ignorecase = true
--vim.opt.smartcase = true

vim.opt.termguicolors = true
--vim.opt.background = "dark"

-- minor aesthetics
vim.opt.showmode = false
vim.opt.scrolloff = 3
vim.opt.signcolumn = "yes"

-- backspace
vim.opt.backspace = { "start", "eol", "indent" }

--split windows
vim.opt.splitright = true --split vertical window to the right
vim.opt.splitbelow = true --split horizontal window to the bottom

vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.opt.colorcolumn = "100"

-- clipboard
-- Ingoring in favor of more control on what gets copied
vim.opt.clipboard:append("unnamedplus") --use system clipboard as default
vim.opt.hlsearch = true

-- for easy mouse resizing, just incase
vim.opt.mouse = "a"

-- Make trailing spaces and tabs visible
vim.opt.list = true
vim.opt.listchars = {
    tab = "» ",
    trail = "·",
    nbsp = "󱁐"
}
