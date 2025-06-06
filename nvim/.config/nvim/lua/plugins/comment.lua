return {
    "numToStr/Comment.nvim",
    opts = {},
    config = function()
        require('Comment').setup()

        local api = require('Comment.api')

        vim.keymap.set('n', 'gcp', function()
            -- Get the content of the current line
            local line = vim.api.nvim_get_current_line()
            local pos = vim.api.nvim_win_get_cursor(0)
            local row, col = pos[1], pos[2]
            -- 
            -- Duplicate current line below
            vim.api.nvim_buf_set_lines(0, row, row, false, { line })
            -- Comment the original line
            api.toggle.linewise.current()
            -- Finally move the cursor to the new line
            vim.api.nvim_win_set_cursor(0, { row + 1, col })
        end, { desc = "Comment current and copy down" })

        vim.keymap.set('n', 'gcP', function()
            local line = vim.api.nvim_get_current_line()
            local row = vim.api.nvim_win_get_cursor(0)[1]
            vim.api.nvim_buf_set_lines(0, row, row, false, { line })
            api.toggle.linewise.count(2)
            api.toggle.linewise.current()
        end, { desc = "Comment current and copy up" })
    end
}
