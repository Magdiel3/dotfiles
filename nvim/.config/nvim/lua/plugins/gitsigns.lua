return {
    {
        {
            "sindrets/diffview.nvim",
            enabled = true,
            opts = {
                view = {
                    default = {
                        winbar_info = false,
                        disable_diagnostics = true,
                    },
                },
            },
            keys = {
                {"<leader>gD", "<CMD>DiffviewOpen<CR>", desc = "Open Diffview",},
            }
        },
        {
            "lewis6991/gitsigns.nvim",
            opts = {
                auto_attach = true,
                current_line_blame = true,
                diff_opts = {
                    vertical = true,
                    internal = false,
                    linematch = false,
                },
                signs = {
                    changedelete = { text = '┃' },
                },
            },
            config = function(_, opts)
                require("gitsigns").setup(opts)
                local wk = require("which-key")
                wk.add({
                    { "<leader>g", group = "+Git", icon = { icon = "", color = "red"}, },
                    {
                        "<leader>gh",
                        "<CMD>Gitsigns preview_hunk_inline<CR>",
                        desc = "Preview hunk",
                        icon = { icon = "", color = "red" },
                    },
                    {
                        "<leader>gH",
                        "<CMD>Gitsigns reset_hunk<CR>",
                        desc = "Reset hunk",
                        icon = { icon = "", color = "red"},
                    },
                    {
                        "<leader>gd",
                        function()
                            vim.cmd("tabnew %")
                            require("gitsigns").diffthis()
                            local ok, _ = pcall(require, "barbecue.ui")
                            if ok then
                                require("barbecue.ui").toggle(false)
                                require("barbecue.ui").update()
                            end
                        end,
                        desc = "Split diff the current file",
                        icon = { icon = "", color = "red"},
                    },
                    {
                        "<leader>gw",
                        "<CMD>Gitsigns toggle_word_diff<CR>",
                        desc = "Toggle highlighting character diff",
                        icon = { icon = "", color = "red"},
                    },
                })
            end,
        },
    },
}
