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
    }
})

require("config.opts")
require("config.lazy")
require("config.parsers")
require("config.project").setup({})
require("config.autochdir").setup()
require("config.keys")

if vim.g.neovide then
    require("config.neovide")
end

vim.cmd("colorscheme tokyonight-night")
