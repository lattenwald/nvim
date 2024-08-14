return {
    {
        "mikavilpas/yazi.nvim",
        event = "VeryLazy",
        keys = {
            -- 👇 in this section, choose your own keymappings!
            {
                "<leader>-",
                "<cmd>Yazi<cr>",
                desc = "Open yazi at the current file",
            },
            {
                -- Open in the current working directory
                "<leader>cw",
                "<cmd>Yazi cwd<cr>",
                desc = "Open the file manager in nvim's working directory" ,
            },
            {
                -- NOTE: this requires a version of yazi that includes
                -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
                '<c-up>',
                "<cmd>Yazi toggle<cr>",
                desc = "Resume the last yazi session",
            },
        },
        ---@type YaziConfig
        opts = {
            -- if you want to open yazi instead of netrw, see below for more info
            open_for_directories = false,

            -- enable these if you are using the latest version of yazi
            -- use_ya_for_events_reading = true,
            -- use_yazi_client_id_flag = true,

            keymaps = {
                show_help = '<f1>',
            },
        },
    },
    {
        'stevearc/oil.nvim',
        enabled = false,
        opts = {},
        -- Optional dependencies
        -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
        dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
    },
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

            vim.keymap.set('n', '<C-f>', '<cmd>NvimTreeToggle<cr>', {desc = "NvimTree toggle"})
        end,
    },
    {
        'nvim-neo-tree/neo-tree.nvim',
        enabled = false,
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
    {
        "sindrets/diffview.nvim",
    }
}
