vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
		local pos = vim.fn.getpos(".")
		local winview = vim.fn.winsaveview()

		-- Get buffer contents and run goimports
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local input = table.concat(lines, "\n")
		local output = vim.fn.system("goimports", input)

		-- Only apply changes if goimports succeeded (no parse errors)
		if vim.v.shell_error == 0 then
			vim.cmd("silent! undojoin")
			local new_lines = vim.split(output, "\n", { trimempty = false })
			-- Remove trailing empty line that vim.split adds
			if new_lines[#new_lines] == "" then
				table.remove(new_lines)
			end
			vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
		end

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
					"tailwindcss",
					"eslint"
				},
				-- auto-install configured servers (with lspconfig)
				automatic_installation = true, -- not the same as ensure_installed
			})

			mason_tool_installer.setup({
				ensure_installed = {
					"prettier", -- prettier formatter
					"stylua", -- lua formatter
					"black", -- python formatter
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
				cmd = { 'svelteserver', '--stdio' },
				filetypes = { 'svelte' },
				root_dir = function(bufnr, on_dir)
					local fname = vim.api.nvim_buf_get_name(bufnr)
					-- Svelte LSP only supports file:// schema.
					-- https://github.com/sveltejs/language-tools/issues/2777
					if vim.uv.fs_stat(fname) ~= nil then
						local root_markers = {
							'package-lock.json',
							'yarn.lock',
							'pnpm-lock.yaml',
							'bun.lockb',
							'bun.lock',
							'deno.lock'
						}

						if vim.fn.has('nvim-0.11.3') == 1 then
							root_markers = { root_markers, { '.git' } }
						else
							root_markers = vim.list_extend(root_markers, { '.git' })
						end

						-- We fallback to the current working directory if no project root is found
						local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
						on_dir(project_root)
					end
				end,
				on_attach = function(client, bufnr)
					-- Workaround to trigger reloading JS/TS files
					-- See https://github.com/sveltejs/language-tools/issues/2008
					vim.api.nvim_create_autocmd('BufWritePost', {
						pattern = { '*.js', '*.ts' },
						group = vim.api.nvim_create_augroup('lspconfig.svelte', {}),
						callback = function(ctx)
							-- internal API to sync changes that have not yet been saved to the file system
							---@diagnostic disable-next-line: param-type-mismatch
							client:notify('$/onDidChangeTsOrJsFile', { uri = ctx.match })
						end,
					})
					vim.api.nvim_buf_create_user_command(bufnr, 'LspMigrateToSvelte5', function()
						client:exec_cmd({
							title = 'Migrate Component to Svelte 5 Syntax',
							command = 'migrate_to_svelte_5',
							arguments = { vim.uri_from_bufnr(bufnr) },
						})
					end, { desc = 'Migrate Component to Svelte 5 Syntax' })
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
			vim.lsp.config("clangd", {
				capabilities = capabilities,
				on_attach = on_attach,
			})

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


			local util = require('lspconfig.util')

			vim.lsp.config("tailwindcss", {
				cmd = { 'tailwindcss-language-server', '--stdio' },
				-- filetypes copied and adjusted from tailwindcss-intellisense
				filetypes = {
					-- html
					'aspnetcorerazor', 'astro', 'astro-markdown', 'blade',
					'clojure', 'django-html', 'htmldjango', 'edge',
					'eelixir', 'elixir', 'ejs', 'erb',
					'eruby', 'gohtml', 'gohtmltmpl', 'haml',
					'handlebars', 'hbs', 'html', 'htmlangular',
					'html-eex', 'heex', 'jade', 'leaf',
					'liquid', 'markdown', 'mdx', 'mustache',
					'njk', 'nunjucks', 'php', 'razor',
					'slim', 'twig',
					-- css
					'css', 'less', 'postcss', 'sass',
					'scss', 'stylus', 'sugarss',
					-- js
					'javascript', 'javascriptreact', 'reason',
					'rescript', 'typescript', 'typescriptreact',
					-- mixed
					'vue', 'svelte', 'templ',
				},
				capabilities = {
					workspace = {
						didChangeWatchedFiles = {
							dynamicRegistration = true,
						},
					},
				},
				settings = {
					tailwindCSS = {
						validate = true,
						lint = {
							cssConflict = 'warning',
							invalidApply = 'error',
							invalidScreen = 'error',
							invalidVariant = 'error',
							invalidConfigPath = 'error',
							invalidTailwindDirective = 'error',
							recommendedVariantOrder = 'warning',
						},
						classAttributes = {
							'class',
							'className',
							'class:list',
							'classList',
							'ngClass',
						},
						includeLanguages = {
							eelixir = 'html-eex',
							elixir = 'phoenix-heex',
							eruby = 'erb',
							heex = 'phoenix-heex',
							htmlangular = 'html',
							templ = 'html',
						},
					},
				},
				before_init = function(_, config)
					if not config.settings then
						config.settings = {}
					end
					if not config.settings.editor then
						config.settings.editor = {}
					end
					if not config.settings.editor.tabSize then
						config.settings.editor.tabSize = vim.lsp.util.get_effective_tabstop()
					end
				end,
				workspace_required = true,
				root_dir = function(bufnr, on_dir)
					local root_files = {
						-- Generic
						'tailwind.config.js',
						'tailwind.config.cjs',
						'tailwind.config.mjs',
						'tailwind.config.ts',
						'postcss.config.js',
						'postcss.config.cjs',
						'postcss.config.mjs',
						'postcss.config.ts',
						-- Django
						'theme/static_src/tailwind.config.js',
						'theme/static_src/tailwind.config.cjs',
						'theme/static_src/tailwind.config.mjs',
						'theme/static_src/tailwind.config.ts',
						'theme/static_src/postcss.config.js',
						-- Fallback for tailwind v4, where tailwind.config.* is not required anymore
						'.git',
					}
					local fname = vim.api.nvim_buf_get_name(bufnr)
					root_files = util.insert_package_json(root_files, 'tailwindcss', fname)
					root_files = util.root_markers_with_field(root_files, { 'mix.lock', 'Gemfile.lock' }, 'tailwind', fname)
					on_dir(vim.fs.dirname(vim.fs.find(root_files, { path = fname, upward = true })[1]))
				end
			})


			local eslint_config_files = {
				'.eslintrc',
				'.eslintrc.js',
				'.eslintrc.cjs',
				'.eslintrc.yaml',
				'.eslintrc.yml',
				'.eslintrc.json',
				'eslint.config.js',
				'eslint.config.mjs',
				'eslint.config.cjs',
				'eslint.config.ts',
				'eslint.config.mts',
				'eslint.config.cts',
			}

			vim.lsp.config("eslint", {
				cmd = { 'vscode-eslint-language-server', '--stdio' },
				filetypes = {
					'javascript',
					'javascriptreact',
					'javascript.jsx',
					'typescript',
					'typescriptreact',
					'typescript.tsx',
					'vue',
					'svelte',
					'astro',
					'htmlangular',
				},
				workspace_required = true,
				on_attach = function(client, bufnr)
					vim.api.nvim_buf_create_user_command(bufnr, 'LspEslintFixAll', function()
						client:request_sync('workspace/executeCommand', {
							command = 'eslint.applyAllFixes',
							arguments = {
								{
									uri = vim.uri_from_bufnr(bufnr),
									version = vim.lsp.util.buf_versions[bufnr],
								},
							},
						}, nil, bufnr)
					end, {})
				end,
				root_dir = function(bufnr, on_dir)
					-- The project root is where the LSP can be started from
					-- As stated in the documentation above, this LSP supports monorepos and simple projects.
					-- We select then from the project root, which is identified by the presence of a package
					-- manager lock file.
					local root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }
					-- Give the root markers equal priority by wrapping them in a table
					root_markers = vim.fn.has('nvim-0.11.3') == 1 and { root_markers, { '.git' } }
							or vim.list_extend(root_markers, { '.git' })

					-- exclude deno
					if vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc', 'deno.lock' }) then
						return
					end

					-- We fallback to the current working directory if no project root is found
					local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()

					-- We know that the buffer is using ESLint if it has a config file
					-- in its directory tree.
					--
					-- Eslint used to support package.json files as config files, but it doesn't anymore.
					-- We keep this for backward compatibility.
					local filename = vim.api.nvim_buf_get_name(bufnr)
					local eslint_config_files_with_package_json =
							util.insert_package_json(eslint_config_files, 'eslintConfig', filename)
					local is_buffer_using_eslint = vim.fs.find(eslint_config_files_with_package_json, {
						path = filename,
						type = 'file',
						limit = 1,
						upward = true,
						stop = vim.fs.dirname(project_root),
					})[1]
					if not is_buffer_using_eslint then
						return
					end

					on_dir(project_root)
				end,
				-- Refer to https://github.com/Microsoft/vscode-eslint#settings-options for documentation.
				settings = {
					validate = 'on',
					---@diagnostic disable-next-line: assign-type-mismatch
					packageManager = nil,
					useESLintClass = false,
					experimental = {
						useFlatConfig = false,
					},
					codeActionOnSave = {
						enable = false,
						mode = 'all',
					},
					format = true,
					quiet = false,
					onIgnoredFiles = 'off',
					rulesCustomizations = {},
					run = 'onType',
					problems = {
						shortenToSingleLine = false,
					},
					-- nodePath configures the directory in which the eslint server should start its node_modules resolution.
					-- This path is relative to the workspace folder (root dir) of the server instance.
					nodePath = '',
					-- use the workspace folder location or the file location (if no workspace folder is open) as the working directory
					workingDirectory = { mode = 'auto' },
					codeAction = {
						disableRuleComment = {
							enable = true,
							location = 'separateLine',
						},
						showDocumentation = {
							enable = true,
						},
					},
				},
				before_init = function(_, config)
					-- The "workspaceFolder" is a VSCode concept. It limits how far the
					-- server will traverse the file system when locating the ESLint config
					-- file (e.g., .eslintrc).
					local root_dir = config.root_dir

					if root_dir then
						config.settings = config.settings or {}
						config.settings.workspaceFolder = {
							uri = root_dir,
							name = vim.fn.fnamemodify(root_dir, ':t'),
						}

						-- Support flat config files
						-- They contain 'config' in the file name
						local flat_config_files = vim.tbl_filter(function(file)
							return file:match('config')
						end, eslint_config_files)

						for _, file in ipairs(flat_config_files) do
							local found_files = vim.fn.globpath(root_dir, file, true, true)

							-- Filter out files inside node_modules
							local filtered_files = {}
							for _, found_file in ipairs(found_files) do
								if string.find(found_file, '[/\\]node_modules[/\\]') == nil then
									table.insert(filtered_files, found_file)
								end
							end

							if #filtered_files > 0 then
								config.settings.experimental = config.settings.experimental or {}
								config.settings.experimental.useFlatConfig = true
								break
							end
						end

						-- Support Yarn2 (PnP) projects
						local pnp_cjs = root_dir .. '/.pnp.cjs'
						local pnp_js = root_dir .. '/.pnp.js'
						if type(config.cmd) == 'table' and (vim.uv.fs_stat(pnp_cjs) or vim.uv.fs_stat(pnp_js)) then
							config.cmd = vim.list_extend({ 'yarn', 'exec' }, config.cmd --[[@as table]])
						end
					end
				end,
				handlers = {
					['eslint/openDoc'] = function(_, result)
						if result then
							vim.ui.open(result.url)
						end
						return {}
					end,
					['eslint/confirmESLintExecution'] = function(_, result)
						if not result then
							return
						end
						return 4 -- approved
					end,
					['eslint/probeFailed'] = function()
						vim.notify('[lspconfig] ESLint probe failed.', vim.log.levels.WARN)
						return {}
					end,
					['eslint/noLibrary'] = function()
						vim.notify('[lspconfig] Unable to find ESLint library.', vim.log.levels.WARN)
						return {}
					end,
				},
			})
		end,

	},
	{
		"lervag/vimtex",
		lazy = false,
	}
}
