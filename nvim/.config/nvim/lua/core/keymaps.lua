local opts = { noremap = true, silent = true }

-- Set the leader key to Space Bar " "
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Move selection around the editor
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

-- Use double j to exit from insert mode
vim.api.nvim_set_keymap('i', 'jj', '<Esc>l', { noremap = true, silent = true })

-- Easier navigation through the editor
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join next line kwwping cursor position" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Go to next result and center the matching line" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Go to previous result and center the matching line" })

--Indentation basic shortcuts
vim.keymap.set("v", "<", "<gv", vim.tbl_extend("force", opts, { desc = "Indent and reselect" }))
vim.keymap.set("v", ">", ">gv", vim.tbl_extend("force", opts, { desc = "Undo indent and reselect" }))

-- Yank/paste shortcuts
vim.keymap.set("x", "<leader>p", [["_dP]], {
    desc = "Replace selection with previous yanked text"
})
vim.keymap.set("v", "p", '"_dp', vim.tbl_extend("force", opts, {
    desc = "Paste over selection without yanking replaced text"
}))
vim.keymap.set("n", "<leader>Y", [["+Y]], vim.tbl_extend("force", opts, {
    desc = "Yank current line to system clipboard"
}))
vim.keymap.set("v", "<leader>y", [["+y]], vim.tbl_extend("force", opts, {
    desc = "Yank selection to system clipboard"
}))
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

-- ctrl c as escape cuz Im lazy to reach up to the esc key
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "<C-c>", ":nohl<CR>", { desc = "Clear search highlight", silent = true })

-- ctrl s to escape editing and save dile
vim.keymap.set({ "n", "i" }, "<C-s>", "<Esc><CMD>w<CR>", { desc = "Exit editing and save", silent = true })

-- Unmaps Q in normal mode (seems like an old functionality hard to exit)
vim.keymap.set("n", "Q", "<nop>")

-- Prevent x from overriding current copy
vim.keymap.set("n", "x", '"_x', opts)

-- -- Replace the word cursor is on globally
-- vim.keymap.set("n", "<leader>pR", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
--    { desc = "Replace word cursor is on globally" })

-- -- Executes shell command from in here making file executable
-- vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "makes file executable" })

-- Hightlight yanking
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

-- Tab stuff
vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "open new tab" })
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "close current tab" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "go to next" })
vim.keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "go to pre" })
vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "open current file in new tab" })
vim.keymap.set("n", "t1", "<cmd>tabn 1<CR>") --open the 1st tab
vim.keymap.set("n", "t2", "<cmd>tabn 2<CR>") --open the 2nd tab
vim.keymap.set("n", "t3", "<cmd>tabn 3<CR>") --open the 3rd tab
vim.keymap.set("n", "t4", "<cmd>tabn 4<CR>") --open the 4th tab
vim.keymap.set("n", "t5", "<cmd>tabn 5<CR>") --open the 5th tab


-- Split management
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })
vim.keymap.set("n", "<leader>sz", "<C-w>|", { desc = "(Vertically) Maximize window" })

-- Copy filepath to the clipboard
vim.keymap.set("n", "<leader>cP", function()
  local filePath = vim.fn.expand("%:~") -- Gets the file path relative to the home directory
  vim.fn.setreg("+", filePath) -- Copy the file path to the clipboard register
  print("File path copied to clipboard: " .. filePath) -- Optional: print message to confirm
end, { desc = "Copy filepath to clipboard" })
