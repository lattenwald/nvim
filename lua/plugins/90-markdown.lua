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
        "brianhuster/live-preview.nvim",
        dependencies = {
            "folke/snacks.nvim",
        },
    },
}
