return {
	--I got annoyed so I just stopped using it for a bit
	"folke/which-key.nvim",
    enabled = true,
	event = "VeryLazy",
	init = function()
	    vim.o.timeout = true
	    vim.o.timeoutlen = 1500
	end,
	opts = {
        preset = "helix",
    },
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Local Keymaps (which-key)",
        },
    },
}
