local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", -- latest stable release
            lazypath,
        })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ' '

require'lazy'.setup('plugins', {
    defaults = {
        version = "*"
    }
})

-- vim.g.vimwiki_list = {{path = '~/vimwiki/', syntax = 'markdown', ext = '.md'}}

-- command-line completion
vim.opt.wildmenu = true
vim.opt.wildmode = 'longest:full,full'
vim.api.nvim_set_keymap('c', '<up>', 'wildmenumode() ? "<left>" : "<up>"', { noremap = true, expr = true })
vim.api.nvim_set_keymap('c', '<down>', 'wildmenumode() ? "<right>" : "<down>"', { noremap = true, expr = true })
vim.api.nvim_set_keymap('c', '<left>', 'wildmenumode() ? "<up>" : "<left>"', { noremap = true, expr = true })
vim.api.nvim_set_keymap('c', '<right>', 'wildmenumode() ? "<down>" : "<right>"', { noremap = true, expr = true })

-- clipboard
vim.opt.clipboard = "unnamedplus"

-- misc
vim.o.hidden = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.cmdheight = 2
vim.o.updatetime = 500
vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.tabstop=4
vim.o.shiftwidth=4
vim.o.visualbell = false
vim.o.expandtab = true

vim.o.number = true
vim.api.nvim_set_keymap('n', '<C-N>', ':set number!<cr>', {desc = "Toggle line numbers"})
vim.api.nvim_set_keymap('i', '<C-N>', '<esc>:set number!<cr>i', {desc = "Toggle line numbers"})

-- show tabs and trailing spaces
vim.o.listchars = "tab:→ ,trail:·"
vim.o.list = true
vim.api.nvim_set_keymap('n', '<C-P>', ':set list!<cr>', {desc = "Toggle show whitespaces"})
vim.api.nvim_set_keymap('i', '<C-P>', '<esc>:set list!<cr>i', {desc = "Toggle show whitespaces"})
-- TODO show list status in statusline

-- chdir
vim.api.nvim_set_keymap('n', '<leader>cd', ':cd %:p:h<cr>:pwd<cr>', {desc = "Change dir to current file"})
vim.api.nvim_create_autocmd('BufEnter', {command = [[silent! lcd %:p:h]]})

vim.api.nvim_set_keymap('c', '<S-Insert>', '<C-R>+', {desc = "Insert from buffer in command mode"})

-- move tabs
vim.api.nvim_set_keymap('n', '<C-S-PageDown>', ':tabmove +1<cr>', {desc = "Move tab right"})
vim.api.nvim_set_keymap('n', '<C-S-PageUp>', ':tabmove -1<cr>', {desc = "Move tab left"})

-- move between windows
vim.api.nvim_set_keymap('n', '<M-left>', '<C-w><left>', {desc = "Go to left window"})
vim.api.nvim_set_keymap('n', '<M-right>', '<C-w><right>', {desc = "Go to right window"})
vim.api.nvim_set_keymap('n', '<M-up>', '<C-w><up>', {desc = "Go to top window"})
vim.api.nvim_set_keymap('n', '<M-down>', '<C-w><down>', {desc = "Go to bottom window"})

-- lsp keybindings
vim.keymap.set('n', ']g', vim.diagnostic.goto_next, {silent = true, desc = "LSP: go to next diagnostic"})
vim.keymap.set('n', '[g', vim.diagnostic.goto_prev, {silent = true, desc = "LSP: go to previous diagnostic"})
vim.keymap.set('n', '<leader>d', vim.lsp.buf.hover, {silent = true, desc = "LSP: hover"})

-- remove trailing whitespaces on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        pattern = { "*" },
        command = [[%s/\s\+$//e]],
    })

vim.o.guifont = 'Hack:h11'
