return {
  'saghen/blink.cmp',
  dependencies = {
    { 'rafamadriz/friendly-snippets' },
    {
      "github/copilot.vim",
      cmd = "Copilot",
      event = "BufWinEnter",
      config = function()
        -- Instead of blocking the copilot suggestions, with the expected way, have autocomonds
        -- to hide the suggestion when the BlinkCmp menu is open and show it again when the menu
        -- is closed.
        vim.api.nvim_create_autocmd('User', {
          pattern = 'BlinkCmpMenuOpen',
          callback = function()
            -- Send the <C-]> key to Copilot to dismiss the suggestion
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-]>', true, false, true), 'n', true)
            vim.b.copilot_suggestion_hidden = true
          end,
        })
        vim.api.nvim_create_autocmd('User', {
          pattern = 'BlinkCmpMenuClose',
          callback = function()
            vim.b.copilot_suggestion_hidden = false
          end,
        })
      end,
    },
    {
      'fang2hou/blink-copilot',
      opts = {
        max_completions = 3,
        max_attempts = 4,
        kind_name = "Copilot",
        kind_icon = " ",
        kind_hl = false,
        debounce = -10,
      }
    },
  },


  -- use a release tag to download pre-built binaries
  version = '1.*',
  -- instead, build the binary here
  -- build = 'cargo build --release',

  opts = {
    enabled = function()
      return not vim.tbl_contains({ "copilot-chat", "copilot-overview" }, vim.bo.filetype)
    end,

    keymap = {
      preset = 'super-tab',
      ['<C-j>'] = { 'select_next', 'fallback' },
      ['<C-k>'] = { 'select_prev', 'fallback' },
      ['<C-n>'] = { 'fallback' },
      ['<C-p>'] = { 'fallback' },
    },

    appearance = {
      nerd_font_variant = 'mono'
    },

    completion = {
      documentation = {
        auto_show = true,
      },
      menu = {
        auto_show = false,
      },
      ghost_text = { enabled = true },
    },

    signature = { enabled = true },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', },
      -- default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
      providers = {
        copilot = {
          name = "copilot",
          module = "blink-copilot",
          score_offset = 100,
          async = true,
        },
      },
    },

    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" }
}

