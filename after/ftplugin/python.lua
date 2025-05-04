require("config.utils").lsp_setup("basedpyright", {
    settings = {
        basedpyright = {
            typeCheckingMode = "standard",
        },
    },
    position_encoding = "utf-16",
})
require("config.utils").lsp_setup("ruff")
