vim.keymap.set("n", "<leader>E", function()
    require("telescope").extensions.rest.select_env()
end, { desc = "Select REST env", buffer = true })
vim.keymap.set("n", "<leader>R", "<Cmd>Rest run<CR>", { desc = "Rest run", buffer = true })
