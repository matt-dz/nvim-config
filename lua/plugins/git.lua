return {
	{
		"akinsho/git-conflict.nvim",
		version = "*",
		config = true,
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
				end

				-- Navigation
				map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
				map("n", "[h", function() gs.nav_hunk("prev") end, "Previous hunk")

				-- Actions
				map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
				map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
				map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
				map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
				map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
				map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
				map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
				map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
				map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line (full)")
				map("n", "<leader>hB", function() gs.blame() end, "Blame buffer")
				map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle line blame")
				map("n", "<leader>hd", gs.diffthis, "Diff this")
				map("n", "<leader>hD", function() gs.diffthis("~") end, "Diff this ~")
				map("n", "<leader>td", gs.preview_hunk_inline, "Preview hunk inline")

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
			end,
		},
	},
	{
		"linrongbin16/gitlinker.nvim",
		cmd = "GitLink",
		keys = {
			{ "<leader>gy", "<cmd>GitLink<cr>", mode = { "n", "v" }, desc = "Copy git link" },
			{ "<leader>gY", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Open git link" },
			{
				"<leader>gH",
				function()
					Snacks.gitbrowse({ what = "repo" })
				end,
				desc = "Open repo home",
			},
		},
		opts = {},
	},
}
