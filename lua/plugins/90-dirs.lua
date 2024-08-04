return {
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {"nvim-tree/nvim-web-devicons"},
        opts = {
            sync_root_with_cwd = true,
            update_focused_file = {
                enable = true,
                update_root = true,
            },
            on_attach = function(bufnr)
                local api = require'nvim-tree.api'
                vim.keymap.set('n', '<c-cr>', api.node.open.tab_drop , {desc = 'Open node in new tab'})

                api.config.mappings.default_on_attach(bufnr)
            end,
        },
        config = function(_, opts)
            local nvim_tree = require'nvim-tree'
            nvim_tree.setup(opts)

            nvim_tree.disable_netrw = false
            nvim_tree.hijack_netrw  = true

            vim.keymap.set('n', '<C-S-f>', '<cmd>NvimTreeToggle<cr>', {desc = "NvimTree toggle"})
        end,
    },
    {
        'nvim-neo-tree/neo-tree.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
            'MunifTanjim/nui.nvim',
        },
        opts = {
            window = {
                mappings = {
                    ["<C-Enter>"] = "open_tabnew",
                },
            },
            follow_current_file = {
                enabled = true,
            },
            use_libuv_file_watcher = true,
        },
        config = function(_, opts)
            require'neo-tree'.setup(opts)

            vim.keymap.set('n', '<C-f>', '<cmd>Neotree reveal toggle<cr>', {desc = "Neotree current file"})
            vim.keymap.set('n', '<C-b>', '<cmd>Neotree buffers float toggle<cr>', {desc = "Neotree buffers"})
        end,
    },
}
