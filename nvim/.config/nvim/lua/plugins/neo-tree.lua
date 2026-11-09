return {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons',
        'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
        { '<leader>e', '<cmd>Neotree toggle left<cr>', desc = 'Toggle file explorer sidebar' },
        { '<leader>o', '<cmd>Neotree focus left<cr>', desc = 'Focus file explorer sidebar' },
        { '<leader>bf', '<cmd>Neotree toggle show buffers left<cr>', desc = 'Toggle open buffers sidebar' },
    },
    opts = {
        close_if_last_window = true,
        enable_git_status = true,
        enable_diagnostics = true,
        sources = { 'filesystem', 'buffers', 'git_status' },
        source_selector = {
            winbar = true,
            sources = {
                { source = 'filesystem', display_name = ' 󰉓 Files ' },
                { source = 'buffers',    display_name = ' 󰈚 Buffers ' },
                { source = 'git_status', display_name = ' 󰊢 Git ' },
            },
        },
        window = {
            position = 'left',
            width = 35,
            mappings = {
                ['<cr>'] = 'open',
                ['<space>'] = 'toggle_node',
                ['o'] = 'open',
                ['v'] = 'open_vsplit',
                ['s'] = 'open_split',
                ['t'] = 'open_tabnew',
                ['C'] = 'close_node',
                ['z'] = 'close_all_nodes',
                ['R'] = 'refresh',
                ['a'] = 'add',
                ['d'] = 'delete',
                ['r'] = 'rename',
                ['c'] = 'copy',
                ['m'] = 'move',
                ['q'] = 'close_window',
                ['?'] = 'show_help',
            },
        },
        filesystem = {
            follow_current_file = { enabled = true },
            use_libuv_file_watcher = true,
            filtered_items = {
                visible = false,
                hide_dotfiles = false,
                hide_gitignored = true,
            },
        },
        buffers = {
            follow_current_file = { enabled = true },
            show_unloaded = true,
            before_render = function(state)
                -- pcall-wrap to tolerate `git status` failures (e.g. permission-denied
                -- subdirs) that would otherwise abort the buffers source render
                pcall(require('neo-tree.git').status, state.path, state.git_base_by_worktree)
            end,
        },
        default_component_configs = {
            indent = {
                with_markers = true,
                with_expanders = true,
            },
            git_status = {
                symbols = {
                    added = '',
                    modified = '',
                    deleted = '✖',
                    renamed = '󰁕',
                    untracked = '',
                    ignored = '',
                    unstaged = '󰄱',
                    staged = '',
                    conflict = '',
                },
            },
        },
    },
}
