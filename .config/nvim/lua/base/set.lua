vim.opt.nu = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.ignorecase = true
vim.opt.smartindent = true
vim.opt.smartcase = true
vim.opt.spelloptions = "camel"
vim.opt.iskeyword:remove('_')
vim.opt.spelllang = 'en_us'
vim.opt.spell = true

vim.opt.wrap = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.scrolloff = 2

vim.api.nvim_command('set clipboard=unnamedplus')
