return {
    {
        "psliwka/termcolors.nvim",
    },
    {
        "akinsho/toggleterm.nvim",
        opts = {
            insert_mappings = true,
            start_in_insert = true,
            autochdir = false,
        },
        config = function(_, opts)
            require'toggleterm'.setup(opts)
            local Terminal = require("toggleterm.terminal").Terminal
            local term = Terminal:new({
                dir = "git_dir",
            })
            vim.keymap.set({ "n", "v", "i", "t" }, "<c-`>", function()
                term:toggle()
            end, { desc = "Toggle terminal" })
        end,
    },
}
