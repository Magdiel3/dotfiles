return {
    {
        "lukas-reineke/indent-blankline.nvim",
        opts = {},
        main = "ibl",
        config = function ()
            require("ibl").setup()
        end,
    },
    {
        "nvimdev/indentmini.nvim",
        enabled = false,
        opts = {},
    }
}
