return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
            latex = { enabled = false },
            -- file_types = { "markdown", "Avante" },
        },
        -- ft = { "markdown", "Avante" },
    },
    {
        "serenevoid/kiwi.nvim",
        opts = {
            {
                name = "vimwiki",
                path = vim.fn.expand("~/vimwiki"),
            },
            {
                name = "personal",
                path = vim.fn.expand("~/wiki/personal"),
            },
        },
        keys = {
            { "<leader>wi", ':lua require("kiwi").open_wiki_index()<cr>', desc = "Open Wiki index" },
            { "<leader>x", ':lua require("kiwi").todo.toggle()<cr>', desc = "Toggle checkbox" },
            {
                "<leader>ww",
                ':lua require("kiwi").open_wiki_index("vimwiki")<cr>',
                desc = "Open index of vimwiki",
            },
            {
                "<leader>wp",
                ':lua require("kiwi").open_wiki_index("personal")<cr>',
                desc = "Open index of personal wiki",
            },
            { "T", ':lua require("kiwi").todo.toggle()<cr>', desc = "Toggle Markdown Task" },
        },
        lazy = true,
    },
    {
        "epwalsh/obsidian.nvim",
        lazy = true,
        event = { "BufReadPre ~/cloud/obsidian/**.md" },
        opts = {
            ui = { enable = false },
            workspaces = {
                {
                    name = "Personal",
                    path = "~/cloud/obsidian/Personal",
                },
                {
                    name = "Kribrum",
                    path = "~/cloud/obsidian/Kribrum",
                },
            },
            log_level = vim.log.levels.DEBUG,
            -- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
            completion = {
                -- Set to false to disable completion.
                nvim_cmp = true,
                -- Trigger completion at 2 chars.
                min_chars = 2,
            },
            follow_url_func = function(url)
                -- Open the URL in the default web browser.
                vim.fn.jobstart({ "xdg-open", url }) -- linux
            end,
        },
        config = function(_, opts)
            require("obsidian").setup(opts)

            -- Optional, override the 'gf' keymap to utilize Obsidian's search functionality.
            vim.keymap.set("n", "gf", function()
                if require("obsidian").util.cursor_on_markdown_link() then
                    return "<cmd>ObsidianFollowLink<CR>"
                else
                    return "gf"
                end
            end, { noremap = false, expr = true })
        end,
    },
    {
        "3rd/image.nvim",
        enabled = false,
        opts = {
            backend = "ueberzug",
        },
    },
}
