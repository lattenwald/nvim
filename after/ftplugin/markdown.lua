require("config.utils").mason_install("marksman")
vim.keymap.set("n", "<leader>o", ":silent !xdg-open %<CR>", { buffer = true, desc = "Open in browser" })
