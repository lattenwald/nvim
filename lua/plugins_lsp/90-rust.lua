return {
    {
        "mrcjkb/rustaceanvim",
        lazy = true,
        ft = "rust",
        config = function()
            vim.g.rustaceanvim = function()
                local cfg = require("rustaceanvim.config")
                return {
                    server = {
                        capabilities = require("cmp_nvim_lsp").default_capabilities(),
                        on_attach = function(_client, bufnr)
                            print("rustaceanvim attached!")
                            -- vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                            vim.keymap.set("n", "<leader>R", function()
                                vim.cmd.RustLsp("reloadWorkspace")
                            end, { silent = true, buffer = bufnr, desc = "Reload workspace" })
                            vim.keymap.set("n", "<leader>A", function()
                                vim.cmd.RustLsp({ "hover", "actions" })
                            end, {
                                silent = true,
                                buffer = bufnr,
                                desc = "Rust hover action",
                            })
                            vim.keymap.set("n", "<C-f5>", function()
                                vim.cmd.RustLsp("debug")
                            end, { silent = true, buffer = bufnr, desc = "RustLsp debug" })
                            vim.keymap.set("n", "<C-S-f5>", function()
                                vim.cmd.RustLsp({ "debug", bang = true })
                            end, { silent = true, buffer = bufnr, desc = "RustLsp debug!" })
                        end,
                    },
                    dap = {
                        -- autoload_configurations = true,
                        adapter = require("rustaceanvim.config").get_codelldb_adapter(
                            "/usr/lib/codelldb/adapter/codelldb",
                            "/usr/lib/codelldb/lldb/lib/liblldb.so"
                        ),
                    },
                }
            end
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

            vim.keymap.set("n", "<leader>ct", crates.toggle, { silent = true, desc = "Crates: toggle" })
            vim.keymap.set("n", "<leader>cr", crates.reload, { silent = true, desc = "Crates: reload" })

            vim.keymap.set(
                "n",
                "<leader>cv",
                crates.show_versions_popup,
                { silent = true, desc = "Crates: versions popup" }
            )
            vim.keymap.set(
                "n",
                "<leader>cf",
                crates.show_features_popup,
                { silent = true, desc = "Crates: features popup" }
            )
            vim.keymap.set(
                "n",
                "<leader>cd",
                crates.show_dependencies_popup,
                { silent = true, desc = "Crates: dependencies popup" }
            )

            vim.keymap.set("n", "<leader>cu", crates.update_crate, { silent = true, desc = "Crates: update crate" })
            vim.keymap.set("v", "<leader>cu", crates.update_crates, { silent = true, desc = "Crates: update crates" })
            vim.keymap.set(
                "n",
                "<leader>ca",
                crates.update_all_crates,
                { silent = true, desc = "Crates: update all crates" }
            )
            vim.keymap.set("n", "<leader>cU", crates.upgrade_crate, { silent = true, desc = "Crates: upgrade crate" })
            vim.keymap.set("v", "<leader>cU", crates.upgrade_crates, { silent = true, desc = "Crates: upgrade crates" })
            vim.keymap.set(
                "n",
                "<leader>cA",
                crates.upgrade_all_crates,
                { silent = true, desc = "Crates: upgrade all crates" }
            )

            vim.keymap.set(
                "n",
                "<leader>cx",
                crates.expand_plain_crate_to_inline_table,
                { silent = true, desc = "Crates: expand crate" }
            )
            vim.keymap.set(
                "n",
                "<leader>cX",
                crates.extract_crate_into_table,
                { silent = true, desc = "Crates: extract crate" }
            )

            vim.keymap.set(
                "n",
                "<leader>cH",
                crates.open_homepage,
                { silent = true, desc = "Crates: open crate homepage" }
            )
            vim.keymap.set(
                "n",
                "<leader>cR",
                crates.open_repository,
                { silent = true, desc = "Crates: open crate repository" }
            )
            vim.keymap.set(
                "n",
                "<leader>cD",
                crates.open_documentation,
                { silent = true, desc = "Crates: open crate documentation" }
            )
            vim.keymap.set(
                "n",
                "<leader>cC",
                crates.open_crates_io,
                { silent = true, desc = "Crates: open crate crates.io" }
            )
            vim.keymap.set("n", "<leader>cL", crates.open_lib_rs, { silent = true, desc = "Crates: open crate lib.rs" })
        end,
    },
}
