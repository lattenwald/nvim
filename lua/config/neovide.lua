vim.o.guifont = "FiraCode Nerd Font:h10"
-- vim.o.guifont = "Hack:h10"
vim.opt.linespace = -1 -- Negative linespace to tighten rows

vim.o.mouse = "a"

vim.g.neovide_scroll_animation_length = 0.1

vim.opt.title = true
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        local repo = require("config.utils").current_repo_name()
        local s
        if not repo or repo == "" then
            s = "%F"
        else
            s = string.format("%s :: %s", repo, "%f")
        end
        vim.opt.titlestring = string.format("%s - Neovide", s)
    end,
})
