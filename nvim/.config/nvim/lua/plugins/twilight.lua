return {
  "folke/twilight.nvim",
  opts = {
    dimming = {
      alpha = 0.5,
    }
  },
  keys = {
    {
      "<leader>T",
      function()
        require("twilight").toggle()
      end,
      desc = "Toggle Twilight (dimming inactive code)",
    }
  }
}
