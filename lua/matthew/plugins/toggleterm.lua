return {
	-- amongst your other plugins
	'akinsho/toggleterm.nvim',
	version = "*",
	keys = {
		{"<leader>tt"}
	},
	config = function()
		require("toggleterm").setup({})
		vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<cr>", { desc = "Opens a terminal in cwd" })
		vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { desc = "Escapes terminal mode" })
		vim.keymap.set("t", "jk", [[<C-\><C-n>]], { desc = "Escapes terminal mode" })
	end,
}
