return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        main = 'nvim-treesitter.configs',
        opts = {
            ensure_installed = {
                'bash',
                'c',
                'diff',
                'html',
                'lua',
                'luadoc',
                'markdown',
                'markdown_inline',
                'python',
                'query',
                'vim',
                'vimdoc'
            },
            auto_install = false,
            highlight = { enable = true },
            indent = { enable = false },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<Enter>",
                    node_incremental = "<Enter>",
                    scope_incremental = false,
                    node_decremental = "<S-CR>",
                }
            }
        },
    },
    { "nvim-treesitter/nvim-treesitter-context", enabled = false},
    { "nvim-treesitter/nvim-treesitter-testobjects", enabled = false},
}
