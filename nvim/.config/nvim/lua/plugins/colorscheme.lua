return {
    { "folke/tokyonight.nvim" },
    { "Mofiqul/vscode.nvim" },
    { "ellisonleao/gruvbox.nvim" },
    {
        "askfiy/visual_studio_code",
        lazy = false,
        config = function()
            local vsc_thm = require("visual_studio_code")
            vsc_thm.setup({
                mode = "dark",
                hooks = {
                    after = function(conf, colors, utils)
                        require("visual_studio_code.utils").hl.bulk_set({
                            StatusLine = { fg = "#a6a6a6", bg = "#3a3d41" },
                            StatusLineNC = { link = "StatusLine" },
                        })
                    end,
                }
            })
        end,
    },
}
