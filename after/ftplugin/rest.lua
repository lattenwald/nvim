-- TODO do we need this file at all?
require("config.utils").mason_install("kulala-fmt")
require("conform").setup({
    formatters_by_ft = {
        rest = { "kulala-fmt" },
    },
})
