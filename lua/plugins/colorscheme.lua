return {
	{ "catppuccin/nvim",          name = "catppuccin", priority = 1000 },
	{ "ellisonleao/gruvbox.nvim", name = "gruvbox",    priority = 1000 },
	{ "rebelot/kanagawa.nvim",    name = "kanagawa",   priority = 1000 },
	{
		"scottmckendry/cyberdream.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("cyberdream")
		end,
		keys = {
			{ "<leader>tt", "<cmd>CyberdreamToggleMode<cr>", desc = "Toggle light/dark mode" },
		},
	}
}
