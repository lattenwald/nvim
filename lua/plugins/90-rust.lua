return {
    {
        "mrcjkb/rustaceanvim",
        lazy = false,
        init = function()
            vim.notify("setting up rustaceanvim")
            vim.g.rustaceanvim = {
                server = {
                    default_settings = {
                        ["rust-analyzer"] = {
                            cargo = {
                                loadOutDirsFromCheck = true,
                                buildScripts = {
                                    enable = true,
                                },
                            },
                            procMacro = {
                                enable = true,
                            },
                        },
                    },
                },
            }
        end,
    },
    {
        "saecki/crates.nvim",
        tag = "stable",
        opts = {
            lsp = {
                enabled = true,
                actions = true,
                completion = true,
                hover = true,
            },
            popup = {
                autofocus = true,
            },
        },
        config = function(_, opts)
            local crates = require("crates")
            crates.setup(opts)

            vim.api.nvim_create_autocmd("BufRead", {
                pattern = "Cargo.toml",
                -- stylua: ignore
                callback = function(args)
                    vim.keymap.set("n", "<leader>ct", crates.toggle, { silent = true, buffer = args.buf, desc = "Crates: toggle" })
                    vim.keymap.set("n", "<leader>cr", crates.reload, { silent = true, buffer = args.buf, desc = "Crates: reload" })

                    vim.keymap.set("n", "<leader>cv", crates.show_versions_popup, { silent = true, buffer = args.buf, desc = "Crates: versions popup" })
                    vim.keymap.set("n", "<leader>cf", crates.show_features_popup, { silent = true, buffer = args.buf, desc = "Crates: features popup" })
                    vim.keymap.set("n", "<leader>cd", crates.show_dependencies_popup, { silent = true, buffer = args.buf, desc = "Crates: dependencies popup" })

                    vim.keymap.set("n", "<leader>cu", crates.update_crate, { silent = true, buffer = args.buf, desc = "Crates: update crate" })
                    vim.keymap.set("v", "<leader>cu", crates.update_crates, { silent = true, buffer = args.buf, desc = "Crates: update crates" })
                    vim.keymap.set("n", "<leader>ca", crates.update_all_crates, { silent = true, buffer = args.buf, desc = "Crates: update all crates" })
                    vim.keymap.set("n", "<leader>cu", crates.upgrade_crate, { silent = true, buffer = args.buf, desc = "Crates: upgrade crate" })
                    vim.keymap.set("v", "<leader>cu", crates.upgrade_crates, { silent = true, buffer = args.buf, desc = "Crates: upgrade crates" })
                    vim.keymap.set("n", "<leader>ca", crates.upgrade_all_crates, { silent = true, buffer = args.buf, desc = "Crates: upgrade all crates" })

                    vim.keymap.set("n", "<leader>cx", crates.expand_plain_crate_to_inline_table, { silent = true, buffer = args.buf, desc = "Crates: expand crate" })
                    vim.keymap.set("n", "<leader>cx", crates.extract_crate_into_table, { silent = true, buffer = args.buf, desc = "Crates: extract crate" })

                    vim.keymap.set("n", "<leader>ch", crates.open_homepage, { silent = true, buffer = args.buf, desc = "Crates: open crate homepage" })
                    vim.keymap.set("n", "<leader>cr", crates.open_repository, { silent = true, buffer = args.buf, desc = "Crates: open crate repository" })
                    vim.keymap.set("n", "<leader>cd", crates.open_documentation, { silent = true, buffer = args.buf, desc = "Crates: open crate documentation" })
                    vim.keymap.set("n", "<leader>cc", crates.open_crates_io, { silent = true, buffer = args.buf, desc = "Crates: open crate crates.io" })
                    vim.keymap.set("n", "<leader>cl", crates.open_lib_rs, { silent = true, buffer = args.buf, desc = "Crates: open crate lib.rs" })
                end,
            })
        end,
    },
}
