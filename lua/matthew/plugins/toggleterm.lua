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
		vim.keymap.set("n", "<C-\\>", "<cmd>ToggleTerm<cr>", { desc = "Escapes terminal mode" })
		vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { desc = "Escapes terminal mode" })
		vim.keymap.set("t", "jk", [[<C-\><C-n>]], { desc = "Escapes terminal mode" })
		vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]])
	        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]])
	        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]])
	        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]])
	        vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]])
	end,
}
