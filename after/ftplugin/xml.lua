local utils = require("config.utils")

local opts = {
    cmd = { "lemminx" },
    filetypes = { "xml" },
    settings = {
        xml = {
            validation = {
                enabled = true,
                resolveExternalEntities = true,
            },
            catalogs = {
                "~/.config/xml-catalogs/catalog.xml",
            },
            format = {
                enabled = true,
                splitAttributes = "preserve",
            },
        },
    },
}

utils.mason_install("lemminx", function()
    utils.lsp_setup("lemminx", opts)
end)
