require("config.utils").mason_install("stylua")
require("config.utils").lsp_setup("lua_ls")
require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
    },
})
