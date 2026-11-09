vim.env["CODECOMPANION_TOKEN_PATH"] = vim.fn.expand("~/.config")
return {
    {
        "olimorris/codecompanion.nvim",
        version = "^18.0.0",
        enabled = true,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "ravitemer/mcphub.nvim",
            "ravitemer/codecompanion-history.nvim", -- history extension
        },
        config = function(_, opts)
            local wk = require("which-key")
            wk.add({
                { "<leader>c", group = "+Code Companion", mode = { "n", "v" }, icon = "" },
                {
                    "<leader>ci",
                    "<cmd>CodeCompanion<CR>",
                    mode = { "n", "v" },
                    desc = "Open Code Companion Inline",
                    icon = "",
                },
                {
                    "<leader>cc",
                    "<cmd>CodeCompanionChat Toggle<CR>",
                    mode = { "n", "v" },
                    desc = "Toggle Code Companion Chat",
                    icon = "",
                },
                {
                    "<leader>ca",
                    "<cmd>CodeCompanionChat Add<CR>",
                    mode = "v",
                    desc = "Add Selection to Code Companion Chat",
                    icon = "",
                },
            })
            require("codecompanion").setup({
                opts = {
                    log_level = "DEBUG",
                },
                interactions = {
                    chat = {
                        adapter = "copilot",
                    },
                    inline = {
                        adapter = "copilot",
                    },
                },
                extensions = {
                    mcphub = {
                        callback = "mcphub.extensions.codecompanion",
                        opts = {
                            make_vars = true,
                            make_slash_commands = true,
                            show_result_in_chat = true
                        }
                    },
                    history = {
                        opts = {
                            dir_to_save = vim.fn.stdpath("data") .. "/codecompanion_chats.json",
                        }
                    },
                }
            })
        end,
    },
        {
        "ravitemer/mcphub.nvim",
        enabled = true,
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        build = "npm install -g mcp-hub@latest",  -- Installs `mcp-hub` node binary globally
        config = function()
            require("mcphub").setup()
        end
    },

}
