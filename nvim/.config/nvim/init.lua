_G.nvim_start_time = vim.loop.hrtime()
_G.nvim_loaded_time = nil
require("core")
require("config.lazy")
require("current-theme")
_G.nvim_loaded_time = vim.loop.hrtime()
