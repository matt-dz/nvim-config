return {
	-- amongst your other plugins
	'akinsho/toggleterm.nvim',
	version = "*",
	lazy = false,
	config = function()
		require("toggleterm").setup({})
		vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<cr>", { desc = "Opens a terminal in cwd" })
	end,
}
