return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    --dependencies = { "echasnovski/mini.icons" },
    opts = {},
    keys={
        { 
            "<leader>ff",
            function() require('fzf-lua').files() end,
            desc="[F]ind [F]iles in project directory"
        },
        { 
            "<leader>fg",
            function() require('fzf-lua').live_grep() end,
            desc="[F]ind by [G]repping in project directory"
        },
        { 
            "<leader>fC",
            function()
                require('fzf-lua').colorschemes({
                    actions = {
                        ["default"] = function(selected)
                            local colorscheme = selected[1]
                            vim.cmd.colorscheme(colorscheme)

                            -- Update the config file directly calling colorescheme and setting var
                            local config_file = vim.fn.stdpath("config") .. "/lua/current-theme.lua"
                            local new_command = string.format(
                                'vim.cmd("colorscheme %s")\nvim.g.colors_name = "%s"\n',
                                colorscheme, colorscheme
                            )
                            -- Write the file
                            local file = io.open(config_file, "w")
                            if file then
                                file:write(new_command)
                                file:close()
                            end
                        end,
                    },
                })
            end,
            desc="[F]ind new [C]olorscheme for neovim"
        },
        { 
            "<leader>fc",
            function() require('fzf-lua').files({cwd=vim.fn.stdpath("config")}) end,
            desc="[F]ind in neovim [C]onfiguration"
        },
        {
            "<leader>fh",
            function() require("fzf-lua").helptags({
                actions   = {
                    -- Use the default vertival split help opener
                    --["default"]  = require("fzf-lua").actions.help_vert,
                    -- Use a custom max_width vertical split
                    ["default"] = function(selected, opts)
                        if selected == 0 then return end
                        require("fzf-lua").actions.help_vert(selected, opts)
                        vim.cmd("vert res 85")
                    end
                },
            }) end,
            desc = "[F]ind [H]elp",
        },
        {
            "<leader>fk",
            function()
                require("fzf-lua").keymaps()
            end,
            desc = "[F]ind [K]eymaps",
        },
        {
            "<leader>fb",
            function()
                require("fzf-lua").builtin()
            end,
            desc = "[F]ind [B]uiltin FZF",
        },
        {
            "<leader>fw",
            function()
                require("fzf-lua").grep_cword()
            end,
            desc = "[F]ind current [W]ord",
        },
        {
            "<leader>fW",
            function()
                require("fzf-lua").grep_cWORD()
            end,
            desc = "[F]ind current [W]ORD",
        },
        {
            "<leader>fd",
            function()
                require("fzf-lua").diagnostics_document()
            end,
            desc = "[F]ind [D]iagnostics",
        },
        {
            "<leader>fr",
            function()
                require("fzf-lua").resume()
            end,
            desc = "[F]ind [R]esume",
        },
        {
            "<leader>fo",
            function()
                require("fzf-lua").oldfiles()
            end,
            desc = "[F]ind [O]ld Files",
        },
        {
            "<leader><leader>",
            function()
                require("fzf-lua").buffers()
            end,
            desc = "[,] Find existing buffers",
        },
        {
            "<leader>/",
            function()
                require("fzf-lua").lgrep_curbuf()
            end,
            desc = "[/] Live grep the current buffer",
        },
    }
}
