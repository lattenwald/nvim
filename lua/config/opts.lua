vim.o.guifont = "Hack:h10"
vim.g.neovide_scroll_animation_length = 0.1
vim.o.mouse = "a"

-- clipboard
vim.opt.clipboard = "unnamedplus"

-- misc
vim.o.hidden = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.cmdheight = 2
vim.o.updatetime = 500
vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.visualbell = false
vim.o.expandtab = true
vim.o.scl = "yes:1"

vim.o.number = true

-- remove trailing whitespaces on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" },
    command = [[%s/\s\+$//e]],
})
