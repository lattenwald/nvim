-- https://blog.epheme.re/software/nvim-latex.html
-- and some additions

local bufnr = vim.api.nvim_get_current_buf()

vim.g.vimtex_view_method = "zathura"

vim.keymap.set('n', '<leader>ll', '<cmd>VimtexCompile<CR>', { silent = true, buffer = bufnr, desc = 'TeX compile' })

-- From: https://github.com/lervag/vimtex/blob/master/doc/vimtex.txt#L4671-L4713
vim.o.foldmethod = "expr"
vim.o.foldexpr="vimtex#fold#level(v:lnum)"
vim.o.foldtext="vimtex#fold#text()"
-- I like to see at least the content of the sections upon opening
vim.o.foldlevel=2
