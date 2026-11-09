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
                    merge_tool = {
                        layout = 'diff3',
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
                        "<leader>gs",
                        function()
                            require('gitsigns').blame_line({full=true,})
                        end,
                        desc = "Show full blame for this line",
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
                    {
                        "<leader>gc",
                        function()
                            require('fzf-lua').git_commits({
                                actions = {
                                    ['default'] = function(selected)
                                        if not selected or #selected == 0 then return end
                                        local hash = selected[1]:match('^(%S+)')
                                        if hash then
                                            require('diffview')
                                            vim.cmd('DiffviewOpen ' .. hash .. '^..' .. hash)
                                        end
                                    end,
                                },
                            })
                        end,
                        desc = "Open DiffView for a commit",
                        icon = { icon = "", color = "red" },
                    },
                })
            end,
        },
    },
}
