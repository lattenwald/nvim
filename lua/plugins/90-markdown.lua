return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
            latex = { enabled = false },
            file_types = { "markdown", "Avante", "codecompanion" },
        },
        ft = { "markdown", "Avante", "codecompanion" },
    },
    {
        -- Using lvim-tech's fork with fix for server nil race condition (PR #348)
        "lvim-tech/live-preview.nvim",
        dependencies = {
            "folke/snacks.nvim",
        },
    },
}
