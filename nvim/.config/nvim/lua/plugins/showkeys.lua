return {
  "nvzone/showkeys",
  cmd = "ShowkeysToggle",
  lazy = false,
  opts = {
    timeout = 1,
    maxkeys = 5,
  },
  config = function(_, opts)
    require("showkeys").setup(opts)
    vim.keymap.set(
        "n",
        "<leader>S",
        "<CMD>ShowkeysToggle<CR>",
        {
          noremap = true,
          silent = true,
          desc = "Toggle Showkeys",
        }
    )
  end,
}
