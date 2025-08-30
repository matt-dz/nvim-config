local map = vim.keymap.set

function CopyLineToClipboard()
	vim.cmd('normal! "+yy')
end

function CopyFileToClipboard()
	vim.cmd('normal! ggVG"+y')
end

map('v', '<leader>yc', '"+y', { noremap = true, silent = true })
map('v', '<leader>yy', ':lua CopyLineToClipboard()<CR>', { noremap = true, silent = true })
map('n', '<leader>yf', ':lua CopyFileToClipboard()<CR>', { noremap = true, silent = true })
map('n', '<leader>ww', ':w<CR>', { noremap = true, silent = true })
map('n', '<leader>wq', ':wq<CR>', { noremap = true, silent = true })
map('n', '<leader>qq', ':q<CR>', { noremap = true, silent = true })
map('n', '<leader>qd', ':q!<CR>', { noremap = true, silent = true })
map('n', '<leader>cc', ':nohl<CR>', { noremap = true, silent = true })
