return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("catppuccin-mocha")
		end
	},
	{ "ellisonleao/gruvbox.nvim", name = "gruvbox", priority = 1000 },
	{ "rebelot/kanagawa.nvim", name = "kanagawa", priority = 1000 },
}
