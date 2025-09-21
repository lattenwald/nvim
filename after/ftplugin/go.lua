require("config.utils").mason_install("gopls")
require("config.utils").mason_install("delve")

require("conform").setup({
    formatters_by_ft = {
        go = { "gofmt" },
    },
})
