require("config.utils").lsp_setup("nil", {
    cmd = { "nil" },
    filetypes = { "nix" },
    root_markers = { "flake.nix", ".git" },
})

require("conform").setup({
    formatters_by_ft = {
        nix = { "nixpkgs_fmt" },
    },
})

