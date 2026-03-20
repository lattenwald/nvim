require("config.utils").mason_install("gopls")
require("config.utils").mason_install("delve")

require("config.utils").mason_install("golangci-lint-langserver")
vim.lsp.config("golangci_lint_ls", {
    cmd = { "golangci-lint-langserver" },
    filetypes = { "go", "gomod" },
    root_markers = { ".golangci.yml", ".golangci.yaml", ".golangci.toml", "go.mod" },
    init_options = {
        command = { "golangci-lint", "run", "--output.json.path=stdout", "--show-stats=false" },
    },
})
vim.lsp.enable("golangci_lint_ls")

require("conform").setup({
    formatters_by_ft = {
        go = { "gofmt" },
    },
})
