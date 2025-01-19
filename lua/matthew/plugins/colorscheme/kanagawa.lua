return {
	"rebelot/kanagawa.nvim",
	lazy = false,
	config = function()
		require("kanagawa").setup()
		vim.cmd("colorscheme kanagawa-dragon")
	end,
}
