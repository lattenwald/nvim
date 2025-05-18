vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2

require("config.utils").mason_install("djlint")
require("conform").setup({
    formatters_by_ft = {
        htmldjango = { "djlint" },
    },
})

require("luasnip").filetype_extend("htmldjango", { "html" })
