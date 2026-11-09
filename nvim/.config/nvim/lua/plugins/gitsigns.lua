return {
    {
        {
            "sindrets/diffview.nvim",
            enabled = true,
            opts = {
                view = {
                    default = {
                        winbar_info = false,
                        disable_diagnostics = true,
                    },
                    merge_tool = {
                        layout = 'diff3',
                        disable_diagnostics = true,
                    },
                },
            },
            keys = {
                {"<leader>gD", "<CMD>DiffviewOpen<CR>", desc = "Open Diffview",},
            }
        },
        {
            "lewis6991/gitsigns.nvim",
            opts = {
                auto_attach = true,
                current_line_blame = true,
                diff_opts = {
                    vertical = true,
                    internal = false,
                    linematch = false,
                },
                signs = {
                    changedelete = { text = '┃' },
                },
            },
            config = function(_, opts)
                require("gitsigns").setup(opts)
                local wk = require("which-key")
                local function gp_trim(str)
                    return (str:gsub("%s+$", ""))
                end

                -- Gather everything needed to build a GitHub web link for the
                -- current buffer/line. Returns a context table or nil (and
                -- notifies) when the buffer is not in a usable git repo.
                local function gp_context()
                    local file = vim.fn.expand("%:p")
                    if file == "" then
                        vim.notify("No file in current buffer", vim.log.levels.WARN)
                        return nil
                    end

                    local dir = vim.fn.fnamemodify(file, ":h")
                    local function git(cmd)
                        return gp_trim(vim.fn.system(
                            "git -C " .. vim.fn.shellescape(dir) .. " " .. cmd
                        ))
                    end

                    local root = git("rev-parse --show-toplevel")
                    if vim.v.shell_error ~= 0 or root == "" then
                        vim.notify("Not inside a git repository", vim.log.levels.WARN)
                        return nil
                    end

                    local remote = git("config --get remote.origin.url")
                    if remote == "" then
                        vim.notify("No 'origin' remote found", vim.log.levels.WARN)
                        return nil
                    end

                    -- Normalize remote URL into host + owner/repo for a web link
                    local host, path, authority
                    authority, path = remote:match("^ssh://([^/]+)/(.+)$")
                    if not authority then
                        authority, path = remote:match("^https?://([^/]+)/(.+)$")
                    end
                    if authority then
                        -- strip any optional userinfo (user[:pass]@)
                        host = authority:gsub(".*@", "")
                    else
                        -- scp-like syntax, possibly using an ssh config Host alias
                        host, path = remote:match("^[^/]-@([^:/]+):(.+)$")
                        if not host then
                            host, path = remote:match("^([^:/]+):(.+)$")
                        end
                    end
                    if not host then
                        vim.notify("Unsupported remote URL: " .. remote, vim.log.levels.WARN)
                        return nil
                    end
                    path = path:gsub("%.git$", "")

                    -- Resolve ssh config Host aliases (e.g. GitHubM3 -> github.com)
                    local resolved = gp_trim(vim.fn.system(
                        "ssh -G " .. vim.fn.shellescape(host)
                            .. " 2>/dev/null | awk '/^hostname /{print $2; exit}'"
                    ))
                    if resolved ~= "" then
                        host = resolved
                    end

                    return {
                        git = git,
                        host = host,
                        path = path,
                        rel = file:sub(#root + 2),
                        line = vim.fn.line("."),
                    }
                end

                -- Build, copy and report a GitHub permalink for the given ref
                -- (a commit sha or a branch name).
                local function gp_copy(ctx, ref)
                    local url = string.format(
                        "https://%s/%s/blob/%s/%s#L%d",
                        ctx.host, ctx.path, ref, ctx.rel, ctx.line
                    )
                    vim.fn.setreg("+", url)
                    vim.notify("Copied: " .. url)
                end

                wk.add({
                    { "<leader>g", group = "+Git", icon = { icon = "", color = "red"}, },
                    {
                        "<leader>gh",
                        "<CMD>Gitsigns preview_hunk_inline<CR>",
                        desc = "Preview hunk",
                        icon = { icon = "", color = "red" },
                    },
                    {
                        "<leader>gH",
                        "<CMD>Gitsigns reset_hunk<CR>",
                        desc = "Reset hunk",
                        icon = { icon = "", color = "red"},
                    },
                    {
                        "<leader>gs",
                        function()
                            require('gitsigns').blame_line({full=true,})
                        end,
                        desc = "Show full blame for this line",
                    },
                    {
                        "<leader>gd",
                        function()
                            vim.cmd("tabnew %")
                            require("gitsigns").diffthis()
                            local ok, _ = pcall(require, "barbecue.ui")
                            if ok then
                                require("barbecue.ui").toggle(false)
                                require("barbecue.ui").update()
                            end
                        end,
                        desc = "Split diff the current file",
                        icon = { icon = "", color = "red"},
                    },
                    {
                        "<leader>gw",
                        "<CMD>Gitsigns toggle_word_diff<CR>",
                        desc = "Toggle highlighting character diff",
                        icon = { icon = "", color = "red"},
                    },
                    {
                        "<leader>gc",
                        function()
                            require('fzf-lua').git_commits({
                                actions = {
                                    ['default'] = function(selected)
                                        if not selected or #selected == 0 then return end
                                        local hash = selected[1]:match('^(%S+)')
                                        if hash then
                                            require('diffview')
                                            vim.cmd('DiffviewOpen ' .. hash .. '^..' .. hash)
                                        end
                                    end,
                                },
                            })
                        end,
                        desc = "Open DiffView for a commit",
                        icon = { icon = "", color = "red" },
                    },
                    {
                        "<leader>gg",
                        function()
                            local ctx = gp_context()
                            if not ctx then return end
                            gp_copy(ctx, ctx.git("rev-parse HEAD"))
                        end,
                        desc = "Copy GitHub permalink (current commit)",
                        icon = { icon = "", color = "red" },
                    },
                    {
                        "<leader>gG",
                        function()
                            local ctx = gp_context()
                            if not ctx then return end
                            local branches = vim.split(
                                ctx.git("branch --format='%(refname:short)'"),
                                "\n",
                                { trimempty = true }
                            )
                            if #branches == 0 then
                                vim.notify("No local branches found", vim.log.levels.WARN)
                                return
                            end
                            require("fzf-lua").fzf_exec(branches, {
                                prompt = "Branch> ",
                                actions = {
                                    ["default"] = function(selected)
                                        if not selected or #selected == 0 then return end
                                        local branch = vim.trim(selected[1])
                                        if branch ~= "" then
                                            gp_copy(ctx, branch)
                                        end
                                    end,
                                },
                            })
                        end,
                        desc = "Copy GitHub permalink (pick branch)",
                        icon = { icon = "", color = "red" },
                    }
                })
            end,
        },
    },
}
