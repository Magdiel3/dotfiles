return {
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        build = ':TSUpdate',
        config = function()
            -- Install parsers (no-op if already installed)
            require('nvim-treesitter').install({
                'bash', 'c', 'diff', 'html', 'lua', 'luadoc',
                'markdown', 'markdown_inline', 'python', 'query',
                'vim', 'vimdoc',
            })

            -- Enable treesitter highlighting for any filetype that has a parser
            vim.api.nvim_create_autocmd('FileType', {
                callback = function()
                    pcall(vim.treesitter.start)
                end,
            })

            -- Incremental node selection using native treesitter API
            -- Mirrors the old incremental_selection config: <Enter> expands, <S-CR> shrinks
            local node_stack = {}

            local function select_node(node)
                local sr, sc, er, ec = node:range()
                -- The end is exclusive. Column zero ends on the previous line.
                if ec == 0 and er > 0 then
                    er = er - 1
                    local line = vim.api.nvim_buf_get_lines(0, er, er + 1, false)[1] or ''
                    ec = #line
                end
                if vim.fn.mode() == 'v' then vim.cmd('normal! \27') end
                vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
                vim.cmd('normal! v')
                vim.api.nvim_win_set_cursor(0, { er + 1, math.max(0, ec - 1) })
            end

            -- Normal mode: start selection at smallest node under cursor
            vim.keymap.set('n', '<Enter>', function()
                node_stack = {}
                local node = vim.treesitter.get_node()
                if not node then return end
                table.insert(node_stack, node)
                select_node(node)
            end, { desc = 'Start treesitter node selection' })

            -- Visual mode: expand selection to parent node
            vim.keymap.set('x', '<Enter>', function()
                local top = node_stack[#node_stack] or vim.treesitter.get_node()
                if not top then return end
                local parent = top:parent()
                if parent then
                    table.insert(node_stack, parent)
                    select_node(parent)
                end
            end, { desc = 'Expand treesitter selection to parent' })

            -- Visual mode: shrink selection back to previous node
            vim.keymap.set('x', '<S-CR>', function()
                if #node_stack > 1 then
                    table.remove(node_stack)
                    select_node(node_stack[#node_stack])
                end
            end, { desc = 'Shrink treesitter selection to child' })
        end,
    },
    { "nvim-treesitter/nvim-treesitter-context", enabled = false},
    { "nvim-treesitter/nvim-treesitter-testobjects", enabled = false},
}
