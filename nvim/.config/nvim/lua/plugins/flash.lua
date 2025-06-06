return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    highlight = {
      groups = {
        backdrop = "Ignore",
        label = "LineNr",
        match = "Normal",
        current = "Title",
      },
    },
  },
  search = {
    incremental = true,
  },
  jump = {
    autojump = true,
  },
  keys = {
    { "<leader>j", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
  },
}
