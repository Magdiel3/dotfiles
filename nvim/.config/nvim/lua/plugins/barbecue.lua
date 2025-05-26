return {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
        "SmiteshP/nvim-navic",
        "nvim-tree/nvim-web-devicons",
    },
    show_modified = true,
    opts = {},
    keys = {
        {
            "<leader>st",
            function()
                require("barbecue.ui").toggle()
                require("barbecue.ui").update()
            end,
            desc = "Toggle vscode like file path at top of the window",
        },
    },
}
