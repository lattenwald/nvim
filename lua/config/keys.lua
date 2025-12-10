vim.g.mapleader = " "

vim.keymap.set("c", "<S-Insert>", "<C-R>+", { desc = "Insert from buffer in command mode" })

-- move between windows
vim.keymap.set({ "n", "t" }, "<M-left>", "<Cmd>wincmd h<enter>", { desc = "Go to left window" })
vim.keymap.set({ "n", "t" }, "<M-right>", "<Cmd>wincmd l<enter>", { desc = "Go to right window" })
vim.keymap.set({ "n", "t" }, "<M-up>", "<Cmd>wincmd k<enter>", { desc = "Go to top window" })
vim.keymap.set({ "n", "t" }, "<M-down>", "<Cmd>wincmd j<enter>", { desc = "Go to bottom window" })

-- wildmenu (cmdline)
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
function _G.get_wildmenu_key(key_wildmenu, key_regular)
    return vim.fn.wildmenumode() ~= 0 and key_wildmenu or key_regular
end

-----------------------
-- CLIPBOARD SECTION --
-----------------------
-- Normal & Visual: Shift+Insert pastes like Ctrl+V does elsewhere
vim.keymap.set({ "n", "v" }, "<S-Insert>", '"+p', { noremap = true, silent = true })
-- Insert: Shift+Insert inserts the + register without leaving insert mode
vim.keymap.set("i", "<S-Insert>", '<C-R>+', { noremap = true, silent = true })
-- Command-line (/:, ?:, :): Shift+Insert pastes into the prompt
vim.keymap.set("c", "<S-Insert>", '<C-R>+', { noremap = true, silent = true })

-- vim.keymap.set doesn't work
-- Map <Down> to act as <Right> in wildmenu, otherwise as normal <Down>
-- Map <Up> to act as <Left> in wildmenu, otherwise as normal <Up>
vim.api.nvim_set_keymap("c", "<Down>", 'v:lua.get_wildmenu_key("<Right>", "<Down>")', { expr = true, noremap = true })
vim.api.nvim_set_keymap("c", "<Up>", 'v:lua.get_wildmenu_key("<Left>", "<Up>")', { expr = true, noremap = true })

vim.keymap.set({ "n", "v" }, "<leader>p", function()
    require("config.project").list_projects()
end, { desc = "Projects" })

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

vim.keymap.set("t", "<S-Insert>", function()
    vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
end, { desc = "Paste from system clipboard" })

-- Command aliases
vim.api.nvim_create_user_command("DO", function(opts)
    vim.cmd("DiffviewOpen " .. opts.args)
end, {
    nargs = "*",
    complete = function(arg_lead)
        return vim.fn.getcompletion("DiffviewOpen " .. arg_lead, "cmdline")
    end,
})

vim.api.nvim_create_user_command("DC", function()
    vim.cmd("DiffviewClose")
end, { nargs = 0 })
