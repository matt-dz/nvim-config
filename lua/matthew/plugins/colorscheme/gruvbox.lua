return {
	"ellisonleao/gruvbox.nvim",
	config = function()
		require("gruvbox").load()
		vim.cmd("colorscheme gruvbox")
	end,
}
