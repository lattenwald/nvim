vim.filetype.add({
    pattern = {
        [".*.ansible.yaml"] = "yaml.ansible",
        [".*.ansible.yml"] = "yaml.ansible",
    },
    group = { "yaml" },
})
vim.filetype.add({
    filename = {
        ["rebar.config"] = "erlang",
        ["sys.config"] = "erlang",
    },
})
vim.filetype.add({
    pattern = {
        ["sys.config.src.*"] = "erlang",
    },
})
vim.filetype.add({
    filename = {
        ["kamailio.cfg"] = "kamailio",
    },
})
local function in_helm_chart(ft)
    return function(path)
        if require("config.utils").find_project_root(path, { "Chart.yaml" }) then
            return ft
        end
    end
end
vim.filetype.add({
    pattern = {
        [".*/templates/.*%.ya?ml"] = in_helm_chart("helm"),
        [".*/templates/.*%.tpl"] = in_helm_chart("helm"),
        [".*/values.*%.ya?ml"] = in_helm_chart("yaml.helm-values"),
    },
})

require("config.nix")
require("config.opts")
require("config.lazy")
require("config.project").setup()
require("config.autochdir").setup()
require("config.title").setup()
require("config.lsp_mute").setup()
require("config.keys")

require("config.utils").mason_install("tree-sitter-cli")

if vim.g.neovide then
    require("config.neovide")
end

vim.cmd("colorscheme tokyonight-night")
