return {
    "christoomey/vim-tmux-navigator",
    cmd = {
        "TmuxNavigateLeft",
        "TmuxNavigateDown",
        "TmuxNavigateUp",
        "TmuxNavigateRight",
        "TmuxNavigatePrevious",
        "TmuxNavigatorProcessList",
    },
    keys = {
        { "<M-h>", "<CMD>TmuxNavigateLeft<CR>" },
        { "<M-j>", "<CMD>TmuxNavigateDown<CR>" },
        { "<M-k>", "<CMD>TmuxNavigateUp<CR>" },
        { "<M-l>", "<CMD>TmuxNavigateRight<CR>" },
        { "<M-w>", "<CMD>TmuxNavigatePrevious<CR>" },
    },
}
