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
        -- Own fork with server race condition fix (upstream PR #348) until merged
        -- "brianhuster/live-preview.nvim",
        "lattenwald/live-preview.nvim",
        dependencies = {
            "folke/snacks.nvim",
        },
    },
}
