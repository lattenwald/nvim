require("lspconfig").basedpyright.setup({
    settings = {
        basedpyright = {
            typeCheckingMode = "standard",
        },
    },
    position_encoding = "utf-16",
})
require("lspconfig").ruff.setup({})
