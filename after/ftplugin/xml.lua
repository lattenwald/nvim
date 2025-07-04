require("config.utils").mason_install("lemminx")
require("lspconfig").lemminx.setup({
    settings = {
        xml = {
            catalogs = { "~/.cache/lemminx/catalog.xml" },
        },
    },
})
