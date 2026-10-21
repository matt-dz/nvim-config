local map = vim.keymap.set

function CopyLineToClipboard()
	vim.cmd('normal! "+yy')
end

function CopyFileToClipboard()
	vim.cmd('normal! ggVG"+y')
end

function CopyFilenameToClipboard()
	local filepath = vim.fn.expand('%:p')
	if filepath ~= '' then
		vim.fn.setreg('+', filepath, 'v')
		vim.notify('Filename copied to clipboard: ' .. filepath, vim.log.levels.INFO)
	end
end

map('v', '<leader>yc', '"+y', { noremap = true, silent = true })
map('v', '<leader>yy', ':lua CopyLineToClipboard()<CR>', { noremap = true, silent = true })
map('n', '<leader>yf', ':lua CopyFileToClipboard()<CR>', { noremap = true, silent = true })
map('n', '<leader>yn', CopyFilenameToClipboard, { noremap = true, silent = true, desc = 'Copy file path' })
map('n', '<leader>ww', ':w<CR>', { noremap = true, silent = true })
map('n', '<leader>wq', ':wq<CR>', { noremap = true, silent = true })
map('n', '<leader>qq', ':q<CR>', { noremap = true, silent = true })
map('n', '<leader>qd', ':q!<CR>', { noremap = true, silent = true })
map('n', '<leader>cc', ':nohl<CR>', { noremap = true, silent = true })
map('n', '<leader>qa', ':qa<CR>', { noremap = true, silent = true })

-- Disable macro recording
map('n', 'q', '<nop>', { noremap = true, silent = true })
