return {
    "lewis6991/gitsigns.nvim",
    opts = {
        current_line_blame = true,
    },
    keys = {
        {
            "<leader>gw",
            "<CMD>Gitsigns toggle_word_diff<CR>",
            desc = "Toggle highlighting character diff",
        },
    },
}
