require("config.utils").mason_install("basedpyright")
require("config.utils").mason_install("ruff")
if vim.lsp.config["basedpyright"] then
    vim.lsp.config.basedpyright["settings"]["basedpyright"]["typeCheckingMode"] = "standard"
    vim.lsp.config.basedpyright["position_encoding"] = "utf-16"
end
