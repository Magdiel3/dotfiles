return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("oil").setup({
            default_file_explorer = true,
            -- columns = { "icon", "permissions", "size" },
            columns = { "icon", },
            delete_to_trash = true,
            view_options = {
                show_hidden = true,
            },
            skip_confirm_for_simple_edits = true,
            float = {
                max_width = 100,
                max_height = 40,
                border = "rounded",
            },
            preview_win = {
                win_options = {
                    wrap = false,
                    foldenable = false,
                }
            },
            keymaps = {
                ["<C-s>"] = false, -- Use C-s to save changes
                ["q"] = "actions.close", -- Close Oil
            }
        })
        -- Open parent dir over current active window
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
        -- Open parent dir in float window
        vim.keymap.set("n", "<leader>-", require("oil").toggle_float)

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "oil", -- Adjust if Oil uses a specific file type identifier
            callback = function()
                vim.opt_local.cursorline = true
            end,
        })
    end,
}
