
-- -- Function to get the current mode indicator as a single character
local function mode()
  -- Map of modes to their respective shorthand indicators
  local mode_map = {
    n = 'N', -- Normal mode
    i = 'I', -- Insert mode
    v = 'V', -- Visual mode
    [''] = 'V', -- Visual block mode
    V = 'V', -- Visual line mode
    c = 'C', -- Command-line mode
    no = 'N', -- NInsert mode
    s = 'S', -- Select mode
    S = 'S', -- Select line mode
    ic = 'I', -- Insert mode (completion)
    R = 'R', -- Replace mode
    Rv = 'R', -- Virtual Replace mode
    cv = 'C', -- Command-line mode
    ce = 'C', -- Ex mode
    r = 'R', -- Prompt mode
    rm = 'M', -- More mode
    ['r?'] = '?', -- Confirm mode
    ['!'] = '!', -- Shell mode
    t = 'T', -- Terminal mode
  }
  -- Return the mode shorthand or [UNKNOWN] if no match
  return mode_map[vim.fn.mode()] or '[UNKNOWN]'
end

-- Custom location display.
-- Instead of line:column have a line|total_lines col|total_cols when the window width has enough
-- space and fallback to the traditional ln:col when the window is not wide enough
local function custom_location()
    -- Parameter is the window-ID or 0 for current window
    local win_width = vim.api.nvim_win_get_width(0)
    local line = vim.fn.line(".")
    local total_lines = vim.fn.line("$")
    local col = vim.fn.col(".")
    local total_cols = vim.fn.col("$")
    if win_width < 80 then
        return string.format("%d:%d", line, col)
    else
        return string.format("%d|%d %d|%d", line, total_lines, col, total_cols)
    end
end

-- Custom encoding display
-- If the encoding is the expected local encoding, omit pringing it
local function custom_encoding()
    local enc = (vim.bo.fenc or vim.go.enc)
    local ret = enc
    local _
    ret = enc
    if vim.bo.fileformat == "unix" then
        ret, _ = enc:gsub("^utf%-8$","") -- Note: % escapes -
    end
    return ret
end

return {
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require("lualine").setup({
                options = {
                    theme = function()
                        require("current-theme")
                        local schm = tostring(vim.g.colors_name)
                        if schm == "visual_studio_code" or schm == "vscode" then
                            return "vscode_lualine"
                        else
                            return "auto"
                        end
                    end,
                    icons_enabled = true,
                    component_separators = "",
                    section_separators = "",
                    always_show_tabline = false,
                    globalstatus = false,
                },
                sections = {
                    lualine_a = {
                        { mode },
                    },
                    lualine_b = {},
                    lualine_c = {
                        {
                            "filename",
                            symbols = {
                                modified = "*",
                                readonly = "[ro]",
                                unnamed = "[No Name]",
                                newfile = "[New]",
                            },
                            shorting_target = 60,
                            path = 1
                        },
                    },
                    lualine_x = {},
                    lualine_y = {
                        {
                            "space_style",
                            fmt = function(content, context)
                                ---@diagnostic disable-next-line: param-type-mismatch
                                local expand = vim.opt_local.expandtab:get()
                                ---@diagnostic disable-next-line: param-type-mismatch
                                local widht = vim.opt_local.shiftwidth:get()
                                local style = expand and "Spaces" or "Tab Size"
                                return ("%s: %s"):format(style, widht)
                            end,
                        },
                        { custom_encoding },
                        {
                            "fileformat",
                            icons_enabled = false,
                            fmt = function(content, context)
                                local style = {
                                    mac = "CR",
                                    unix = "",
                                    dos = "CRLF",
                                }
                                return style[content]
                            end,
                        },
                        { 
                            "filetype",
                            colored = false,
                        },
                    },
                    lualine_z = {
                        {
                            "progress",
                            fmt = function(content, context)
                                local visual_str = {
                                    ["v"] = true,
                                    ["V"] = true,
                                    ["\22"] = true,
                                }
                                if visual_str[tostring(vim.fn.mode())] then
                                    local ln_beg = vim.fn.line("v")
                                    local ln_end = vim.fn.line(".")
                                    local lines = ln_beg <= ln_end and ln_end - ln_beg + 1 or ln_beg - ln_end + 1
                                    return ("- %d -"):format(tostring(lines))
                                end

                                return content
                            end,
                        },
                        { custom_location },
                    },
                },
                --tabline = {
                --    lualine_a = {"buffers"},
                --    lualine_b = {},
                --    lualine_c = {"branch"},
                --    lualine_x = {},
                --    lualine_y = {},
                --    lualine_z = {"tabs"}
                --},
            })
        end,
    },
}
