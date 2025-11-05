return {
    {
        "mrcjkb/rustaceanvim",
        lazy = false,
        init = function()
            local function load_project_rust_config(start_path)
                local utils = require("config.utils")
                local root = utils.find_project_root(start_path, { ".git", "project-root" })

                if not root then
                    return {}, nil
                end

                local config_file = root .. "/.rust-analyzer.json"

                if vim.fn.filereadable(config_file) == 1 then
                    local content = table.concat(vim.fn.readfile(config_file), "\n")
                    local ok, config = pcall(vim.json.decode, content)
                    if ok and type(config) == "table" then
                        return config, root
                    else
                        vim.notify("Failed to parse " .. config_file .. ": " .. tostring(config), vim.log.levels.WARN)
                    end
                end
                return {}, root
            end

            local default_config = {
                cargo = {
                    loadOutDirsFromCheck = true,
                    buildScripts = {
                        enable = true,
                    },
                },
                procMacro = {
                    enable = true,
                },
            }

            local configured_roots = {}

            vim.g.rustaceanvim = {
                server = {
                    on_attach = function(client, bufnr)
                        local buf_path = vim.api.nvim_buf_get_name(bufnr)
                        if buf_path == "" then
                            return
                        end

                        local project_config, root = load_project_rust_config(buf_path)

                        if root and not configured_roots[root] then
                            configured_roots[root] = true

                            local merged_config = vim.tbl_deep_extend("force", default_config, project_config)

                            client.config.settings["rust-analyzer"] = merged_config
                            client.notify("workspace/didChangeConfiguration", {
                                settings = client.config.settings,
                            })
                        end
                    end,
                    default_settings = {
                        ["rust-analyzer"] = default_config,
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
