return {
    -- Surround
    {
        "echasnovski/mini.surround",
        enabled = false,
        event = { "BufReadPre", "BufNewFile" },
        opts = {},
    },
    -- Get rid of whitespace
    {
        "echasnovski/mini.trailspace",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local miniTrailspace = require("mini.trailspace")

            miniTrailspace.setup({
                only_in_normal_buffers = true,
            })

            -- Ensure highlight never reappears by removing it on CursorMoved
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*",
                callback = function()
                    require("mini.trailspace").trim()
                end,
            })
        end,
    },
    -- Split & join
    {
        "echasnovski/mini.splitjoin",
        config = function()
            local miniSplitJoin = require("mini.splitjoin")
            miniSplitJoin.setup({
                mappings = { toggle = "" }, -- Disable default mapping
            })
            vim.keymap.set(
                { "n", "x" },
                "<leader>J",
                function() miniSplitJoin.join() end,
                { desc = "Join arguments" }
            )
            vim.keymap.set(
                { "n", "x" },
                "<leader>K",
                function() miniSplitJoin.split() end,
                { desc = "Split arguments" }
            )
        end,
    },

}
