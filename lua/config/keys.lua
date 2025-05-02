vim.g.mapleader = " "

vim.keymap.set("c", "<S-Insert>", "<C-R>+", { desc = "Insert from buffer in command mode" })

-- move between windows
vim.keymap.set({ "n", "t" }, "<M-left>", "<Cmd>wincmd h<enter>", { desc = "Go to left window" })
vim.keymap.set({ "n", "t" }, "<M-right>", "<Cmd>wincmd l<enter>", { desc = "Go to right window" })
vim.keymap.set({ "n", "t" }, "<M-up>", "<Cmd>wincmd k<enter>", { desc = "Go to top window" })
vim.keymap.set({ "n", "t" }, "<M-down>", "<Cmd>wincmd j<enter>", { desc = "Go to bottom window" })

-- lsp keybindings
vim.keymap.set("n", "]g", function()
    vim.diagnostic.goto_next()
end, { silent = true, desc = "Go to next diagnostic" })
vim.keymap.set("n", "[g", function()
    vim.diagnostic.goto_prev()
end, { silent = true, desc = "Go to previous diagnostic" })
vim.keymap.set("n", "<leader>d", function()
    vim.lsp.buf.hover()
end, { desc = "LSP Hover" })
vim.keymap.set("n", "<leader>a", function()
    vim.lsp.buf.code_action()
end, { desc = "LSP Code Action" })

-- wildmenu (cmdline)
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
function _G.get_wildmenu_key(key_wildmenu, key_regular)
    return vim.fn.wildmenumode() ~= 0 and key_wildmenu or key_regular
end

-- vim.keymap.set doesn't work
-- Map <Down> to act as <Right> in wildmenu, otherwise as normal <Down>
-- Map <Up> to act as <Left> in wildmenu, otherwise as normal <Up>
vim.api.nvim_set_keymap("c", "<Down>", 'v:lua.get_wildmenu_key("<Right>", "<Down>")', { expr = true, noremap = true })
vim.api.nvim_set_keymap("c", "<Up>", 'v:lua.get_wildmenu_key("<Left>", "<Up>")', { expr = true, noremap = true })

vim.keymap.set("n", "<leader>c<space>", "gcc", { remap = true, desc = "Toggle comment (line)" })
vim.keymap.set("x", "<leader>c<space>", "gc", { remap = true, desc = "Toggle comment (visual)" })

local is_lsp_attached = function(bufnr)
    local clients = vim.lsp.get_clients and vim.lsp.get_clients() or {}
    return next(clients) ~= nil
end

local visible_buffers = function()
    return vim.tbl_map(vim.api.nvim_win_get_buf, vim.api.nvim_list_wins())
end

vim.keymap.set("n", "<esc>", function()
    -- close floats
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win) then
            if vim.api.nvim_win_get_config(win).relative ~= "" then
                vim.api.nvim_win_close(win, false)
            end
        end
    end

    -- remove highights
    vim.cmd("noh")

    -- eh... clear lsp references?
    if is_lsp_attached() then
        vim.lsp.buf.clear_references()
        for _, buffer in pairs(visible_buffers()) do
            vim.lsp.util.buf_clear_references(buffer)
        end
    end
end, { desc = "close floats, clear highligths, etc." })
