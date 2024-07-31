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

current_repo_name = function()
    local dir = vim.fs.find('.git', {
        upward = true,
        stop = vim.loop.os_homedir(),
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    })[1]
    if not(dir) then
        dir = vim.fs.find('Cargo.toml', {
            upward = true,
            stop = vim.loop.os_homedir(),
            path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
        })[1]
    end
    local repo_dir = vim.fs.dirname(dir)
    return vim.fs.basename(repo_dir)
end

require'lazy'.setup('plugins', {
    defaults = {
        version = "*",
        event = "VeryLazy",
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
vim.o.scl = 'yes:1'

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
vim.api.nvim_create_autocmd('BufEnter', {callback = function()
    local r = current_repo_name()
    if r then
        vim.opt.title = true
        vim.opt.titlestring = r .. " :: Neovide"
    else
        vim.opt.title = false
    end
end})

vim.api.nvim_set_keymap('c', '<S-Insert>', '<C-R>+', {desc = "Insert from buffer in command mode"})

-- move tabs
vim.api.nvim_set_keymap('n', '<C-S-PageDown>', ':tabmove +1<cr>', {desc = "Move tab right"})
vim.api.nvim_set_keymap('n', '<C-S-PageUp>', ':tabmove -1<cr>', {desc = "Move tab left"})

-- move between windows
vim.keymap.set({'n', 't'}, '<M-left>', '<Cmd>wincmd h<CR>', {desc = "Go to left window"})
vim.keymap.set({'n', 't'}, '<M-right>', '<Cmd>wincmd l<CR>', {desc = "Go to right window"})
vim.keymap.set({'n', 't'}, '<M-up>', '<Cmd>wincmd k<CR>', {desc = "Go to top window"})
vim.keymap.set({'n', 't'}, '<M-down>', '<Cmd>wincmd j<CR>', {desc = "Go to bottom window"})

-- lsp keybindings
vim.keymap.set('n', ']g', vim.diagnostic.goto_next, {silent = true, desc = "Go to next diagnostic"})
vim.keymap.set('n', '[g', vim.diagnostic.goto_prev, {silent = true, desc = "Go to previous diagnostic"})
-- vim.keymap.set('n', '<leader>d', vim.lsp.buf.hover, {silent = true, desc = "LSP: hover"})

util = require'util';
vim.keymap.set('n', '<esc>', function()
    util.close_floats()
    vim.cmd('noh')
    if util.lsp_active() then
        vim.lsp.buf.clear_references()
        for _, buffer in pairs(util.visible_buffers()) do
            vim.lsp.util.buf_clear_references(buffer)
        end
    end
end, {desc = 'close floats, clear highligths, etc.'})

-- <c-o> and <c-O> to enter insert mode without continuing comments
vim.keymap.set('n', '<c-o>', function()
    local fo = vim.opt.formatoptions:get()
    vim.opt.formatoptions:remove{'c', 'r', 'o'}
    vim.api.nvim_feedkeys('o', 't', true)
    vim.opt.formatoptions = fo
end, {desc = '"o" but without comments'})

-- remove trailing whitespaces on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        pattern = { "*" },
        command = [[%s/\s\+$//e]],
    })

-- add ansible.yaml filetype
vim.filetype.add{
    pattern = {
        ['.*.yaml.ansible'] = 'yaml.ansible'
    }
}

vim.o.guifont = 'Hack:h10'

vim.g.neovide_scroll_animation_length = 0.1

vim.api.nvim_create_autocmd({ 'BufRead', 'BufEnter', 'BufWinEnter' },
    { pattern = {"*.go", "*/go.mod"},
      command = [[set noet ts=4 sw=4]]
})
