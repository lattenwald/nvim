require("config.utils").mason_install("lemminx", function()
    local opts = {
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
    require("lspconfig").lemminx.setup(opts)
end)
