return {
	"rebelot/kanagawa.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("kanagawa").load()
		vim.cmd("colorscheme kanagawa")
	end,
}
