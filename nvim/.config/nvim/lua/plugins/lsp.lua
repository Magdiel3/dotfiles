return {
    'neovim/nvim-lspconfig',
    dependencies = {
        { 'mason-org/mason.nvim', opts = {} },
        'mason-org/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },
        -- Allows extra capabilities provided by blink.cmp
        'saghen/blink.cmp',
    },
    config = function()
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
            callback = function(event)
            local map = function(keys, func, desc, mode)
                mode = mode or 'n'
                vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
            end

            map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
            map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction(s) (Suggestions)', { 'n', 'x' })
            map('grr', require('fzf-lua').lsp_references, '[G]oto [R]eferences')
            map('gri', require('fzf-lua').lsp_implementations, '[G]oto [I]mplementation')

            --  To jump back from the definition, press <C-t>.
            map('grd', require('fzf-lua').lsp_definitions, '[G]oto [D]efinition')

            map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

            map('gO', require('fzf-lua').lsp_document_symbols, 'Open Document Symbols')
            map('gW', require('fzf-lua').lsp_live_workspace_symbols, 'Open Workspace Symbols')
            map('grt', require('fzf-lua').lsp_typedefs, '[G]oto [T]ype Definition')

            map('gl', function() vim.diagnostic.open_float() end, 'Open current line diagnostics')


            ---@param method vim.lsp.protocol.Method
            ---@param bufnr? integer some lsp support methods only in specific files
            ---@return boolean
            local function client_supports_method(client, method, bufnr)
              if vim.fn.has 'nvim-0.11' == 1 then
                return client:supports_method(method, bufnr)
              else
                return client.supports_method(method, { bufnr = bufnr })
              end
            end

            -- -- NOTE: Currently disabling to remove the random distractive highlighting
            -- -- TODO: Programatically toggle this functionality or set a more discrete color
            -- -- The following two autocommands are used to highlight references of the
            -- -- word under your cursor when your cursor rests there for a little while.
            -- --    See `:help CursorHold` for information about when this is executed
            -- --
            -- -- When you move your cursor, the highlights will be cleared (the second autocommand).
            -- local client = vim.lsp.get_client_by_id(event.data.client_id)
            -- if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            --   local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            --   vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            --     buffer = event.buf,
            --     group = highlight_augroup,
            --     callback = vim.lsp.buf.document_highlight,
            --   })
            --
            --   vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            --     buffer = event.buf,
            --     group = highlight_augroup,
            --     callback = vim.lsp.buf.clear_references,
            --   })
            --
            --   vim.api.nvim_create_autocmd('LspDetach', {
            --     group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            --     callback = function(event2)
            --       vim.lsp.buf.clear_references()
            --       vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            --     end,
            --   })
            -- end
            --
            -- -- The following code creates a keymap to toggle inlay hints in your
            -- -- code, if the language server you are using supports them
            -- --
            -- -- This may be unwanted, since they displace some of your code
            -- if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            --     map('<leader>th', function()
            --         vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            --   end, '[T]oggle Inlay [H]ints')
            -- end
        end,
    })

    vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = '󰅚 ',
                [vim.diagnostic.severity.WARN] = '󰀪 ',
                [vim.diagnostic.severity.INFO] = '󰋽 ',
                [vim.diagnostic.severity.HINT] = '󰌶 ',
            },
        },
        virtual_text = {
            source = 'if_many',
            spacing = 2,
            format = function(diagnostic)
                local diagnostic_message = {
                    [vim.diagnostic.severity.ERROR] = diagnostic.message,
                    [vim.diagnostic.severity.WARN] = diagnostic.message,
                    [vim.diagnostic.severity.INFO] = diagnostic.message,
                    [vim.diagnostic.severity.HINT] = diagnostic.message,
                }
                return diagnostic_message[diagnostic.severity]
            end,
        },
    }

    local original_capabilities = vim.lsp.protocol.make_client_capabilities()
    local capabilities = require('blink.cmp').get_lsp_capabilities(original_capabilities)


    local servers = {
        -- clangd = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs

        lua_ls = {
            -- cmd = { ... },
            -- filetypes = { ... },
            -- capabilities = {},
            settings = {
                Lua = {
                    completion = {
                        callSnippet = 'Replace',
                    },
                    -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                    -- diagnostics = { disable = { 'missing-fields' } },
                },
            },
        },
        pyright = {
            settings = {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                        diagnosticMode = "workspace"
                    },
                },
            },
        },
        ruff = {},
        rust_analyzer = {},
    }

    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
        'stylua',
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
            function(server_name)
                local server = servers[server_name] or {}
                server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                require('lspconfig')[server_name].setup(server)
            end,
        },
    }
end,
}
