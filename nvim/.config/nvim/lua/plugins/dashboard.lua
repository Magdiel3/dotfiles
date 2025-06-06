return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function()
    local dashboard = require("alpha.themes.dashboard")

    local function pick_banner()
        local height = vim.api.nvim_win_get_height(0)
        if height > 50 then
            return {
                " ██████   █████           █████       ████████████████████████████",
                "░░██████ ░░███           ░░███       ░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ",
                " ░███░███ ░███   ██████  ███████                                  ",
                " ░███░░███░███  ███░░███░░░███░       ████████████████████████████",
                " ░███ ░░██████ ░███ ░███  ░███       ░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ",
                " ░███  ░░█████ ░███ ░███  ░███ ███                                ",
                " █████  ░░█████░░██████   ░░█████     ████████████████████████████",
                "░░░░░    ░░░░░  ░░░░░░     ░░░░░     ░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ",
                "                                                                  ",
                "                                                                  ",
                "                                                                  ",
                " █████   █████ █████████    █████████               █████         ",
                "░░███   ░░███ ███░░░░░███  ███░░░░░███             ░░███          ",
                " ░███    ░███░███    ░░░  ███     ░░░   ██████   ███████   ██████ ",
                " ░███    ░███░░█████████ ░███          ███░░███ ███░░███  ███░░███",
                " ░░███   ███  ░░░░░░░░███░███         ░███ ░███░███ ░███ ░███████ ",
                "  ░░░█████░   ███    ░███░░███     ███░███ ░███░███ ░███ ░███░░░  ",
                "    ░░███    ░░█████████  ░░█████████ ░░██████ ░░████████░░██████ ",
                "     ░░░      ░░░░░░░░░    ░░░░░░░░░   ░░░░░░   ░░░░░░░░  ░░░░░░  ",
                "                                                                  ",
                "                                                                  ",
            }
        elseif height > 40 then
            return {
                " ██████   █████           █████       █████   █████ █████████    █████████               █████        ",
                "░░██████ ░░███           ░░███       ░░███   ░░███ ███░░░░░███  ███░░░░░███             ░░███         ",
                " ░███░███ ░███   ██████  ███████      ░███    ░███░███    ░░░  ███     ░░░   ██████   ███████   ██████",
                " ░███░░███░███  ███░░███░░░███░       ░███    ░███░░█████████ ░███          ███░░███ ███░░███  ███░░██",
                " ░███ ░░██████ ░███ ░███  ░███        ░░███   ███  ░░░░░░░░███░███         ░███ ░███░███ ░███ ░███████",
                " ░███  ░░█████ ░███ ░███  ░███ ███     ░░░█████░   ███    ░███░░███     ███░███ ░███░███ ░███ ░███░░░ ",
                " █████  ░░█████░░██████   ░░█████        ░░███    ░░█████████  ░░█████████ ░░██████ ░░████████░░██████",
                "░░░░░    ░░░░░  ░░░░░░     ░░░░░          ░░░      ░░░░░░░░░    ░░░░░░░░░   ░░░░░░   ░░░░░░░░  ░░░░░░ ",
                "                                                                                                      ",
                "                                                                                                      ",
            }
        elseif height > 35 then
            return {
                " ███          ███    █████   █████ █████████    █████████               █████         ",
                "░░░███      ███░    ░░███   ░░███ ███░░░░░███  ███░░░░░███             ░░███          ",
                "  ░░░███  ███░       ░███    ░███░███    ░░░  ███     ░░░   ██████   ███████   ██████ ",
                "    ░░░████░         ░███    ░███░░█████████ ░███          ███░░███ ███░░███  ███░░███",
                "     ███░░███        ░░███   ███  ░░░░░░░░███░███         ░███ ░███░███ ░███ ░███████ ",
                "   ███░  ░░░███       ░░░█████░   ███    ░███░░███     ███░███ ░███░███ ░███ ░███░░░  ",
                " ███░      ░░░███       ░░███    ░░█████████  ░░█████████ ░░██████ ░░████████░░██████ ",
                "░░░          ░░░         ░░░      ░░░░░░░░░    ░░░░░░░░░   ░░░░░░   ░░░░░░░░  ░░░░░░  ",
            }
        elseif height > 25 then
            return {
                "███╗   ██╗██╗   ██╗██╗███╗   ███╗",
                "████╗  ██║██║   ██║██║████╗ ████║",
                "██╔██╗ ██║██║   ██║██║██╔████╔██║",
                "██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
                "██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
                "╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
            }
        else
            return {
                "   _  ___   ___     ",
                "  / |/ / | / (_)_ _ ",
                " /    /| |/ / /  ' \\",
                "/_/|_/ |___/_/_/_/_/",
            }
        end
    end

    dashboard.section.header.val = pick_banner
    dashboard.section.header.opts.hl = "AlphaHeader"

    local function get_buttons()
        local buttons = {
            dashboard.button("n", "  New file", ":ene <BAR> startinsert<CR>"),
            dashboard.button("o", "󰈞  Open file", ":FzfLua files<CR>"),
            dashboard.button("r", "  Recent files", ":FzfLua oldfiles<CR>"),
            dashboard.button("q", "  Quit", ":qa<CR>"),
        }

        -- TODO: Make this recalculate the height on each new re-rendering
        if vim.api.nvim_win_get_height(0) > 50 then
            table.insert(buttons, 3, dashboard.button("g", "󰱽 " .. " Grep in Files", ":FzfLua live_grep<CR>"))
        end

        return buttons
    end

    dashboard.section.buttons.val = get_buttons()
    dashboard.section.buttons.opts.hl = "AlphaButtons"

    local function get_nvim_load_time()
        local start = _G.nvim_start_time
        local loaded = _G.nvim_loaded_time
        local now = vim.loop.hrtime()
        local elapsed

        if start then
            if loaded then
                elapsed = (loaded - start) / 1e6
            else
                elapsed = (now - start) / 1e6
            end
            return string.format("%.2f", elapsed)
        else
            return "?"
        end
    end

    dashboard.section.footer.val = function()
        local height = vim.api.nvim_win_get_height(0)
        if height > 30 then
            return { "  LazyVim + Alpha • Loaded in " .. get_nvim_load_time() .. "ms" }
        else
            return { nil }
        end
    end
    dashboard.section.footer.opts.hl = "AlphaFooter"

    dashboard.config.layout = {
      { type = "padding", val = 6 },
      dashboard.section.header,
      { type = "padding", val = 3 },
      dashboard.section.buttons,
      { type = "padding", val = 2 },
      dashboard.section.footer,
    }

    return dashboard.config
  end,
  config = function(_, dashboard_config)
    require("alpha").setup(dashboard_config)

    vim.keymap.set(
        "n",
        "<M-w>",
        function()
            if #vim.fn.getbufinfo({ buflisted = 1}) == 1 then
                vim.cmd("bd")
                require("alpha").start(true)
            else
                vim.cmd("bd")
            end
        end,
        { noremap = true, silent = true, desc = "Delete current buffer" }
    )
  end,
}
