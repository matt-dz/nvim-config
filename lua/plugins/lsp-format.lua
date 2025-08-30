return {
	"lukas-reineke/lsp-format.nvim",
	on_attach = function(client, bufnr)
		require("lsp-format").on_attach(client, bufnr)
	end,
}
