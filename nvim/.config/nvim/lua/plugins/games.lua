return {
    {
      'jim-fx/sudoku.nvim',
      cmd = "Sudoku",
      config = function()
        require("sudoku").setup({
          -- configuration ...
        })
      end
    },
    {
        "csessh/aoc.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        enabled = false,
        opts = {}
    },
}
