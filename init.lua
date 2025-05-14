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
    },
})

require("config.opts")
require("config.lazy")
require("config.project").setup({})
require("config.keys")

vim.cmd("colorscheme tokyonight-night")
