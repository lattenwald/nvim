return {
    {
        "williamboman/mason.nvim",
        enabled = load_lsp,
        opts = {},
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        enabled = load_lsp,
        opts = {
            ensure_installed = {
                -- "codelldb", -- rust dap
                "ansible-language-server",
                "ansible-lint",
                "basedpyright",
                "beautysh", -- sh/zsh/bash/etc formatter
                "clangd", -- C++
                "elixir-ls", -- elixir ls/dap
                "erlang-ls", -- erlang ls/dap
                "gopls", -- go
                "prettierd", -- html/json/css/etc formatter
                "ruff",
                "selene", -- lua LSP
                "shellcheck", -- bash linter
                "stylelint", -- CSS
                "stylua", -- lua formatter
                "texlab", -- LaTeX LSP
                "typescript-language-server", -- typescript, javascript
                "xmlformatter",
            },
            auto_update = true,
            run_on_start = true,
        },
    },
    {
        "neovim/nvim-lspconfig",
        branch = "master",
        version = nil,
        enabled = load_lsp,
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup()

            local lspconfig = require("lspconfig")
            local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- TODO incorporate current code location in statusline
            lspconfig.basedpyright.setup({
                capabilities = cmp_capabilities,
                settings = {
                    basedpyright = {
                        typeCheckingMode = "standard",
                    },
                },
            })

            lspconfig.pylsp.setup({
                capabilities = cmp_capabilities,
                settings = {
                    pylsp = {
                        plugins = {
                            pycodestyle = {
                                maxLineLength = 120,
                            },
                        },
                    },
                },
            })

            lspconfig.perlnavigator.setup({
                settings = {
                    perlnavigator = {
                        includePaths = { "~/perl5/lib/perl5" },
                    },
                },
            })

            lspconfig.markdown_oxide.setup({
                -- Ensure that dynamicRegistration is enabled! This allows the LS to take into account actions like the
                -- Create Unresolved File code action, resolving completions for unindexed code blocks, ...
                capabilities = vim.tbl_deep_extend("force", cmp_capabilities, {
                    workspace = {
                        didChangeWatchedFiles = {
                            dynamicRegistration = true,
                        },
                    },
                }),
            })

            local servers = { "erlangls", "elixirls", "ansiblels", "gopls", "ruff", "texlab", "clangd", "ts_ls" }
            for _, lsp in pairs(servers) do
                lspconfig[lsp].setup({
                    -- on_attach = on_attach,
                    capabilites = cmp_capabilities,
                })
            end

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    print(
                        "LS attached buf=" .. ev.buf .. " client=" .. vim.lsp.get_client_by_id(ev.data.client_id).name
                    )

                    vim.keymap.set(
                        "n",
                        "gr",
                        require("telescope.builtin").lsp_references,
                        { buffer = true, desc = "Jump to reference" }
                    )
                    vim.keymap.set("n", "gd", function()
                        require("telescope.builtin").lsp_definitions({ jump_type = "tab" })
                    end, { buffer = true, desc = "Jump to definition" })
                    vim.keymap.set(
                        "n",
                        "gi",
                        require("telescope.builtin").lsp_implementations,
                        { buffer = true, desc = "Jump to implementation" }
                    )

                    vim.keymap.set(
                        "n",
                        "<leader>d",
                        "<cmd>Lspsaga hover_doc<cr>",
                        { desc = "LSP hover doc", buffer = true }
                    )
                    vim.keymap.set(
                        "n",
                        "gD",
                        "<cmd>Lspsaga peek_definition<cr>",
                        { desc = "LSP peek definition", buffer = true }
                    )
                    vim.keymap.set(
                        "n",
                        "gT",
                        "<cmd>Lspsaga peek_type_definition<cr>",
                        { desc = "LSP peek type definition", buffer = true }
                    )
                    vim.keymap.set(
                        "n",
                        "<leader>v",
                        "<cmd>Lspsaga outline<cr>",
                        { desc = "LSP outline", buffer = true }
                    )
                    vim.keymap.set(
                        "n",
                        "<leader>Q",
                        "<cmd>Lspsaga show_workspace_diagnostics<cr>",
                        { desc = "LSP diagnostics", buffer = true }
                    )

                    vim.keymap.set("n", "<leader>n", function()
                        return ":IncRename " .. vim.fn.expand("<cword>")
                    end, { buffer = true, expr = true, desc = "LSP rename symbol" })

                    vim.keymap.set("n", "<leader>s", function()
                        vim.lsp.buf.format({ async = true })
                    end, { buffer = true, desc = "Format buffer" })

                    -- FIXME this takes precedence over mapping in after/ftplugin/rust.lua, but shouldn't
                    vim.keymap.set(
                        { "n", "v" },
                        "<leader>a",
                        require("code_action_menu").open_code_action_menu,
                        { desc = "LSP code action", buffer = true, remap = false }
                    )
                end,
            })
        end,
    },
    {
        "mfussenegger/nvim-dap-python",
        enabled = load_lsp,
        lazy = true,
        ft = "python",
        config = function()
            require("dap-python").setup("/usr/bin/python")
        end,
    },
    {
        "mfussenegger/nvim-dap",
        enabled = load_lsp,
        dependencies = {
            "theHamsta/nvim-dap-virtual-text",
            "rcarriga/nvim-dap-ui",
            "nvim-telescope/telescope-dap.nvim",
            "jbyuki/one-small-step-for-vimkind", -- LUA DAP adapter
            "nvim-neotest/nvim-nio",
            -- 'ldelossa/nvim-dap-projects',
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            local dap_ui_widgets = require("dap.ui.widgets")

            dapui.setup({})
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP continue" })
            vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP step over" })
            vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP step into" })
            vim.keymap.set("n", "<F12>", dap.step_out, { desc = "DAP step out" })
            vim.keymap.set("n", "<Leader>eb", dap.toggle_breakpoint, { desc = "DAP toggle breakpoint" })
            vim.keymap.set("n", "<Leader>eB", dap.set_breakpoint, { desc = "DAP set breakpoint" })
            vim.keymap.set("n", "<Leader>el", function()
                dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
            end, { desc = "DAP set log breakpoint" })
            vim.keymap.set("n", "<Leader>er", dap.repl.open, { desc = "DAP open repl" })
            vim.keymap.set("n", "<Leader>el", dap.run_last, { desc = "DAP run last" })
            vim.keymap.set({ "n", "v" }, "<Leader>eh", dap_ui_widgets.hover, { desc = "DAP UI hover" })
            vim.keymap.set({ "n", "v" }, "<Leader>ep", dap_ui_widgets.preview, { desc = "DAP preview" })
            vim.keymap.set("n", "<Leader>ef", function()
                dap_ui_widgets.centered_float(dap_ui_widgets.frames)
            end, { desc = "DAP UI frames" })
            vim.keymap.set("n", "<Leader>es", function()
                dap_ui_widgets.centered_float(dap_ui_widgets.scopes)
            end, { desc = "DAP UI scopes" })
        end,
    },
    {
        "nvimtools/none-ls.nvim",
        enabled = load_lsp,
        dependencies = {
            "gbprod/none-ls-shellcheck.nvim",
        },
        config = function()
            local null_ls = require("null-ls")

            local opts = {
                sources = {
                    null_ls.builtins.formatting.stylua,
                    -- null_ls.builtins.formatting.beautysh,
                    null_ls.builtins.formatting.prettierd,
                    -- null_ls.builtins.formatting.xmlformat,

                    null_ls.builtins.diagnostics.ansiblelint,
                    null_ls.builtins.diagnostics.selene,

                    require("none-ls-shellcheck.diagnostics"),
                    require("none-ls-shellcheck.code_actions"),
                },
            }

            null_ls.setup(opts)
        end,
    },
    {
        "weilbith/nvim-code-action-menu",
        enabled = load_lsp,
        lazy = true,
        cmd = { "CodeActionMenu" },
        keys = { "<leader>a" },
    },
    {
        "smjonas/inc-rename.nvim",
        enabled = load_lsp,
        opts = {},
    },
    {
        "nvimdev/lspsaga.nvim",
        enabled = load_lsp,
        version = nil,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            outline = {
                keys = {
                    toggle_or_jump = "<cr>",
                },
            },
            lightbulb = {
                enable = false,
            },
        },
    },
    {
        "linux-cultist/venv-selector.nvim",
        branch = "regexp",
        dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" },
        opts = {
            search = {
                project_venvs = {
                    command = "fd -I 'python$' ~/projects/venvs --full-path",
                },
                hatch_venvs = {
                    command = "fd -I 'python$' ~/.config/hatch/env --full-path",
                },
            },
        },
        -- event = 'VeryLazy', -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
        keys = {
            -- Keymap to open VenvSelector to pick a venv.
            { "<leader>vs", "<cmd>VenvSelect<cr>" },
            -- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
            { "<leader>vc", "<cmd>VenvSelectCached<cr>" },
        },
    },
}
