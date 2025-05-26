return {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
        "SmiteshP/nvim-navic",
        "nvim-tree/nvim-web-devicons",
    },
    show_modified = true,
    lazy = false,
    config = function()
        local bbq = require("barbecue")
        bbq.setup()
        local bbq_ui = require("barbecue.ui")
        bbq_ui.toggle(true)
        bbq_ui.update()
    end,
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
