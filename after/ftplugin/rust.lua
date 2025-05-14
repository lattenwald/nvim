require("config.utils").mason_install("codelldb")

local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set("n", "<leader>A", function()
    vim.cmd.RustLsp("codeAction")
end, { silent = true, buffer = bufnr, desc = "Rust code action" })

vim.keymap.set("n", "<leader>a", function()
    vim.cmd.RustLsp({ "hover", "actions" })
end, { silent = true, buffer = bufnr, desc = "Rust hover actions" })

vim.keymap.set("n", "<leader>D", function()
    vim.cmd.RustLsp({ "renderDiagnostic", "current" })
end, { silent = true, buffer = bufnr, desc = "Rust render diagnostic" })
