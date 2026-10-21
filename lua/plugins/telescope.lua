return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
	},

	config = function()
		local telescope = require("telescope")
		local builtin = require("telescope.builtin")
		local actions = require("telescope.actions")

		telescope.setup({
			defaults = {
				path_display = { "truncate " },
				mappings = {
					i = {
						-- Select the previous search result.
						["<C-k>"] = actions.move_selection_previous,
						-- Select the next search result.
						["<C-j>"] = actions.move_selection_next,
						-- Send selected results to the quickfix list and open it.
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					},
				},
				file_ignore_patterns = { "node_modules", "venv" },
			},
		})

		telescope.load_extension("fzf")

		-- set keymaps
		local keymap = vim.keymap

		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Find recent files" })

		keymap.set("n", "<leader>fs", function()
			builtin.live_grep({ no_ignore = false, hidden = true })
		end, { desc = "Search text in working directory" })

		keymap.set("n", "<leader>ff", function()
			builtin.find_files({ no_ignore = false, hidden = false })
		end, { desc = "Find files (respects ignore rules)" })

		keymap.set("n", "<leader>fi", function()
			builtin.find_files({ no_ignore = false, hidden = true })
		end, { desc = "Find hidden files too (respects ignore rules)" })

		keymap.set("n", "<leader>fa", function()
			builtin.find_files({ no_ignore = true, hidden = true })
		end, { desc = "Find files including hidden and ignored" })
	end,
}
