return {
    {
        "OXY2DEV/markview.nvim",
        lazy = false,
        opts = {
            preview = {
                -- Restore defaults so fzf-lua's nofile/prompt buftypes are ignored,
                -- preventing treesitter nil-node crashes on ModeChanged
                ignore_buftypes = { "nofile", "terminal", "quickfix", "prompt" },
                filetypes = { "markdown", "codecompanion" },
            },
        },
    },
}
