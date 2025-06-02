require("config.utils").mason_install("sqls")
require("config.utils").mason_install("sql-formatter")
require("conform").setup({
    formatters_by_ft = {
        sql = { "sql_formatter" },
    },
})

