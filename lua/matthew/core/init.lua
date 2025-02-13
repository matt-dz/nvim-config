function CopyLineToClipboard()
	vim.cmd('normal! "+yy')
end

function CopyFileToClipboard()
	vim.cmd('normal! ggVG"+y')
end

vim.o.clipboard = "unnamedplus"
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.api.nvim_set_option("number", true)
vim.api.nvim_set_option("relativenumber", true)
vim.api.nvim_set_option("tabstop", 2)
vim.api.nvim_set_option("shiftwidth", 2)
vim.api.nvim_set_option("cursorline", true)
vim.api.nvim_set_keymap('v', '<leader>yc', '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>yy', ':lua CopyLineToClipboard()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>yf', ':lua CopyFileToClipboard()<CR>', { noremap = true, silent = true })

-- vim.opt.mouse = ""
vim.o.termguicolors = true

vim.g.instant_username = "matthew"
