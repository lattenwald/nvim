require("config.utils").mason_install("markdown-oxide")
vim.lsp.config("markdown_oxide", {
    capabilities = { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } },
})
vim.keymap.set("n", "<leader>o", ":silent !xdg-open %<CR>", { buffer = true, desc = "Open in browser" })
