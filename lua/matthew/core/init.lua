vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.api.nvim_set_option('number', true)
vim.api.nvim_set_option('relativenumber', true)
vim.api.nvim_set_option('tabstop', 4)
vim.api.nvim_set_option('shiftwidth', 4)
vim.api.nvim_set_option('cursorline', true)
vim.opt.mouse = ""
vim.o.termguicolors = true

-- Neoformat for format on save
vim.api.nvim_create_augroup('fmt', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'fmt',
  pattern = '*',
  command = 'undojoin | Neoformat'
})

