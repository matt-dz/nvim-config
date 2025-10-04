return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		bigfile = {
			enabled = true,
			notify = true,
			size = 1.5 * 1024 * 1024, -- 1.5 MB
			setup = function(ctx)
				local snacks = require("snacks")
				if vim.fn.exists(":NoMatchParen") ~= 0 then
					vim.cmd([[NoMatchParen]])
				end
				snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
				vim.b.minianimate_disable = true
				vim.schedule(function()
					if vim.api.nvim_buf_is_valid(ctx.buf) then
						vim.bo[ctx.buf].syntax = ctx.ft
					end
				end)
			end,
		},

		dashboard = {
			enabled = true,
			preset = {
				header = [[
██╗   ██╗███████╗     ██████╗ ██████╗ ██████╗ ███████╗
██║   ██║██╔════╝    ██╔════╝██╔═══██╗██╔══██╗██╔════╝
██║   ██║███████╗    ██║     ██║   ██║██║  ██║█████╗
╚██╗ ██╔╝╚════██║    ██║     ██║   ██║██║  ██║██╔══╝
 ╚████╔╝ ███████║    ╚██████╗╚██████╔╝██████╔╝███████╗
  ╚═══╝  ╚══════╝     ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝]],
			},
			sections = {
				{ section = "header" },
				{ icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
				{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
				{ icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
				{ section = "startup" },
				{
					section = "terminal",
					cmd = "pokemon-colorscripts -r --no-title; sleep .1",
					random = 1000,
					pane = 2,
					indent = 4,
					height = 30,
				},
			},
		},

		picker = {
			hidden = true,
			ignored = true,
		},

		explorer = {
			enabled = true,
			win = {
				list = {
					keys = {
						["<BS>"] = "explorer_up",
						["l"] = "confirm",
						["h"] = "explorer_close", -- close directory
						["a"] = "explorer_add",
						["d"] = "explorer_del",
						["r"] = "explorer_rename",
						["c"] = "explorer_copy",
						["m"] = "explorer_move",
						["o"] = "explorer_open", -- open with system application
					},
				},
			},
			config = function(opts)
				local keymap = vim.keymap
				keymap.set("n", "<leader>ee", function() Snacks.explorer.open() end, { desc = "Toggle Explorer" })
				return require("snacks.picker.source.explorer").setup(opts)
			end,
		},

		indent = { enabled = true },
		input = { enabled = true },
		notifier = { enabled = true },
		quickfile = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true }
	},
}
