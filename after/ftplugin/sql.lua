require("config.utils").mason_install("sqls")
require("config.utils").mason_install("sqruff")
require("conform").setup({
    formatters_by_ft = {
        sql = { "sqruff" },
    },
})

