vim.filetype.add({
    pattern = {
        [".*.ansible.yaml"] = "yaml.ansible",
        [".*.ansible.yml"] = "yaml.ansible",
    },
    group = { "yaml" },
})

require("config.opts")
require("config.keys")
require("config.lazy")

require("config.project")

vim.cmd("colorscheme tokyonight-night")
