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

map('v', '<leader>yc', '"+y', { noremap = true, silent = true, desc = 'Copy selection to clipboard' })
map('v', '<leader>yy', ':lua CopyLineToClipboard()<CR>', { noremap = true, silent = true, desc = 'Copy current line to clipboard' })
map('n', '<leader>yf', ':lua CopyFileToClipboard()<CR>', { noremap = true, silent = true, desc = 'Copy file contents to clipboard' })
map('n', '<leader>yn', CopyFilenameToClipboard, { noremap = true, silent = true, desc = 'Copy absolute file path to clipboard' })
map('n', '<leader>ww', ':w<CR>', { noremap = true, silent = true, desc = 'Save file' })
map('n', '<leader>wq', ':wq<CR>', { noremap = true, silent = true, desc = 'Save file and close window' })
map('n', '<leader>qq', ':q<CR>', { noremap = true, silent = true, desc = 'Close window' })
map('n', '<leader>qd', ':q!<CR>', { noremap = true, silent = true, desc = 'Close window without saving' })
map('n', '<leader>cc', ':nohl<CR>', { noremap = true, silent = true, desc = 'Clear search highlighting' })
map('n', '<leader>qa', ':qa<CR>', { noremap = true, silent = true, desc = 'Quit Neovim' })

-- Disable macro recording
map('n', 'q', '<nop>', { noremap = true, silent = true, desc = 'Disable macro recording' })
