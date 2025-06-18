-- TODO do we need this file at all?
require("config.utils").mason_install("kulala-fmt")
require("conform").setup({
    formatters_by_ft = {
        rest = { "kulala-fmt" },
    },
})

local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set("n", "<leader>Rr", function()
    vim.cmd.Rest("run")
end, { silent = true, buffer = bufnr, desc = "REST run" })
vim.keymap.set("n", "<leader>Rl", function()
    vim.cmd.Rest("last")
end, { silent = true, buffer = bufnr, desc = "REST re-run last" })
