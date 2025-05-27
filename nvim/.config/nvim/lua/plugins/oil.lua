return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("oil").setup({
            default_file_explorer = true,
            columns = { "icon", "permissions", "size" },
            delete_to_trash = true,
            view_options = {
                show_hidden = true,
            },
            skip_confirm_for_simple_edits = true,
            float = {
                max_width = 100,
                max_height = 20,
                border = "rounded",
            },
        })
        -- Open parent dir over current active window
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
        -- Open parent dir in float window
        vim.keymap.set("n", "<leader>-", require("oil").toggle_float)
    end,
}
