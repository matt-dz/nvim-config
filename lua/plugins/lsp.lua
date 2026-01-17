vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
		-- Save cursor and view position
		local pos = vim.fn.getpos(".")
		local winview = vim.fn.winsaveview()

		-- Run goimports
		vim.cmd("silent! undojoin | silent! %!goimports")

		-- Restore cursor and view
		vim.fn.setpos(".", pos)
		vim.fn.winrestview(winview)
	end,
})

return {
	{
		"williamboman/mason.nvim",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		config = function()
			-- import mason
			local mason = require("mason")

			-- import mason-lspconfig
			local mason_lspconfig = require("mason-lspconfig")

			local mason_tool_installer = require("mason-tool-installer")

			-- enable mason and configure icons
			mason.setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})

			mason_lspconfig.setup({
				-- list of servers for mason to install
				ensure_installed = {
					"ts_ls",
					"html",
					"cssls",
					"svelte",
					"lua_ls",
					"emmet_ls",
					"pyright",
					"clangd",
					"julials",
					"yamlls",
					"gopls",
				},
				-- auto-install configured servers (with lspconfig)
				automatic_installation = true, -- not the same as ensure_installed
			})

			mason_tool_installer.setup({
				ensure_installed = {
					"prettier", -- prettier formatter
					"stylua", -- lua formatter
					-- "isort", -- python formatter
					"black", -- python formatter
					-- "pylint", -- python linter
					"eslint_d", -- js linter
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			{ "antosha417/nvim-lsp-file-operations", config = true },
		},
		config = function()
			-- import cmp-nvim-lsp plugin
			local cmp_nvim_lsp = require("cmp_nvim_lsp")

			local keymap = vim.keymap -- for conciseness

			local opts = { noremap = true, silent = true }
			local on_attach = function(client, bufnr)
				require("lsp-format").on_attach(client, bufnr)
				opts.buffer = bufnr

				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
			end

			-- used to enable autocompletion (assign to every lsp server config)
			local capabilities = cmp_nvim_lsp.default_capabilities()

			-- Change the Diagnostic symbols in the sign column (gutter)
			-- (not in youtube nvim video)
			local signs = {
				Error = " ",
				Warn = " ",
				Hint = "󰠠 ",
				Info = " ",
			}
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end

			-- configure html server
			vim.lsp.config("html", {
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- configure typescript server with plugin
			vim.lsp.config("ts_ls", {
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- configure css server
			vim.lsp.config("cssls", {
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- configure svelte server
			vim.lsp.config("svelte", {
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					on_attach(client, bufnr)

					vim.api.nvim_create_autocmd("BufWritePost", {
						pattern = { "*.js", "*.ts" },
						callback = function(ctx)
							if client.name == "svelte" then
								client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
							end
						end,
					})
				end,
			})

			-- configure emmet language server
			vim.lsp.config("emmet_ls", {
				capabilities = capabilities,
				on_attach = on_attach,
				filetypes = {
					"html",
					"typescriptreact",
					"javascriptreact",
					"css",
					"sass",
					"scss",
					"less",
					"svelte",
				},
			})

			-- configure python server
			vim.lsp.config("pyright", {
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- configure lua server (with special settings)
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = { -- custom settings for lua
					Lua = {
						-- make the language server recognize "vim" global
						diagnostics = { globals = { "vim" } },
						workspace = {
							-- make language server aware of runtime files
							library = {
								[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								[vim.fn.stdpath("config") .. "/lua"] = true,
							},
						},
					},
				},
			})

			-- configure c++ server
			-- lspconfig["clangd"].setup({
			-- 	capabilities = capabilities,
			-- 	on_attach = on_attach,
			-- })

			vim.lsp.config("prismals", {
				capabilities = capabilities,
				on_attach = on_attach,
			})

			vim.lsp.config("gopls", {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					gopls = {
						analyses = {
							unusedparams = true,
						},
						staticcheck = true,
						gofumpt = true,

					}
				}
			})

			vim.lsp.config("rust_analyzer", {
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					on_attach(client, bufnr)
					-- vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end,
			})

			vim.lsp.config("yamlls", {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					redhat = {
						telemetry = {
							enabled = false
						}
					},
					yaml = {
						format = {
							enable = true
						}
					}
				}
			})
		end,
	},
	{
		"lervag/vimtex",
		lazy = false,
	}
}
