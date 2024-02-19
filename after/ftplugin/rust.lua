local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set("n", "<leader>R", "<cmd>RustLsp reloadWorkspace<CR>", { silent = true, buffer = bufnr, desc = "Reload workspace" })
vim.keymap.set("n", "<leader>a", "<cmd>RustLsp codeAction<CR>", { silent = true, buffer = bufnr, desc = "Code actions" })
vim.keymap.set("n", "<leader>A", "<cmd>RustLsp hover actions<CR>", { silent = true, buffer = bufnr, desc = "Hover action" })

-- vim.g.rustaceanvim.server.on_attach = function(_, bufnr)
--     print("rust LS attached")
-- end

-- vim.g.rustaceanvim.server.on_attach = function(_, bufnr)
--     print("rust LS attached")
--     vim.keymap.set("n", "<leader>A", function() vim.cmd.RustLsp('codeAction') end, { buffer = bufnr, description = "Code action" })
-- end
