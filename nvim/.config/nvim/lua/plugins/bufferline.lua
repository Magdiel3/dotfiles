return {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
        local bufferline = require("bufferline")
        bufferline.setup({
            options = {
                mode = "buffers",
                themable = true,
                separator_style = "thick",
                style_preset = {
                    bufferline.style_preset.no_italic,
                },
                buffer_close_icon = "",
                indicator = { style = "underline" },
            },
        })
        -- Bind tab switching with Alt+TabPosition
        for tab_pos = 1, 8 do
            vim.keymap.set(
                "n",
                "<M-"..tab_pos..">",
                "<Cmd>BufferLineGoToBuffer "..tab_pos.."<CR>",
                { noremap = true, silent = true, desc = "Show buffer tab "..tab_pos }
            )
        end
        vim.keymap.set(
            "n",
            "<M-0>",
            "<Cmd>BufferLineGoToBuffer 1 <CR>",
            { noremap = true, silent = true, desc = "Show first buffer tab" }
        )
        vim.keymap.set(
            "n",
            "<M-9>",
            "<Cmd>BufferLineGoToBuffer -1 <CR>",
            { noremap = true, silent = true, desc = "Show last buffer tab" }
        )
        vim.keymap.set(
            "n",
            "<M-w>",
            "<Cmd>bd<CR>",
            { noremap = true, silent = true, desc = "Delete current buffer" }
        )
    end,
}

