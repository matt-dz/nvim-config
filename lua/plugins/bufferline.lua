return {
	"akinsho/bufferline.nvim",
	dependencies = 'nvim-tree/nvim-web-devicons',
	event = "VeryLazy",
	keys = {
		{ "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Close buffers to the right" },
		{ "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>",  desc = "Close buffers to the left" },
		{ "<leader>bb", ":bd<CR>",                       desc = "Close current buffer" },
		{ "<S-h>",      "<Cmd>BufferLineCyclePrev<CR>",  desc = "Previous buffer" },
		{ "<S-l>",      "<Cmd>BufferLineCycleNext<CR>",  desc = "Next buffer" },
	},
	opts = {
		options = {
			-- stylua: ignore
			close_command = function(n) Snacks.bufdelete(n) end,
			-- stylua: ignore
			right_mouse_command = function(n) Snacks.bufdelete(n) end,
			diagnostics = "nvim_lsp",
			always_show_bufferline = false,
			offsets = {
				{
					filetype = "neo-tree",
					text = "Neo-tree",
					highlight = "Directory",
					text_align = "left",
				},
				{
					filetype = "snacks_layout_box",
				},
			},
		},
	},
	config = function(_, opts)
		require("bufferline").setup(opts)
		-- Fix bufferline when restoring a session
		vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
			callback = function()
				vim.schedule(function()
					pcall(nvim_bufferline)
				end)
			end,
		})
	end,
}
