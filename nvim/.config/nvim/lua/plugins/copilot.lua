return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            { "github/copilot.vim" },
            { "nvim-lua/plenary.nvim", branch = "master" },
        },
        build = "make tiktoken",
        opts = {
            window = {
                width = 0.35,
            },
            chat_autocomplete = true,
            mappings = {
                close = { insert = "" },
            },
        },
        config = function(_, opts)
            local wk = require("which-key")
            wk.add({
                { "<leader>c", group = "+Copilot Chat", mode = { "n", "v" }, icon = "" },
                { "<leader>ce", "<cmd>CopilotChatExplain<CR>", mode = "v", desc = "Explain Code", icon = "" },
                { "<leader>cr", "<cmd>CopilotChatReview<CR>", mode = "v", desc = "Review Code", icon = "" },
                { "<leader>cf", "<cmd>CopilotChatFix<CR>", mode = "v", desc = "Fix Code Issues", icon = "" },
                { "<leader>co", "<cmd>CopilotChatOptimize<CR>", mode = "v", desc = "Optimize Code", icon = "" },
                {
                    "<leader>cc",
                    function () require("CopilotChat").toggle() end,
                    mode = { "n", "v" },
                    desc = "Toggle Copilot Chat",
                    icon = "",
                },
                {
                    "<leader>cC",
                    function()
                        require("CopilotChat").open({
                            selection = require("CopilotChat.select").buffer,
                            highlight_selection = false,
                        })
                    end,
                    desc = "Open Copilot Chat with buffer context",
                    icon = "",
                },
            })
            local chat = require("CopilotChat")
            chat.setup(opts)
            vim.api.nvim_create_autocmd('BufEnter', {
                pattern = 'copilot-*',
                callback = function()
                    vim.opt_local.relativenumber = false
                    vim.opt_local.number = false
                    vim.opt_local.conceallevel = 0
                end
            })
        end,
    },
}
