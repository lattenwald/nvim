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
                "ansible-language-server",
                "ansible-lint",
                "basedpyright",
                "beautysh", -- sh/zsh/bash/etc formatter
                "clangd", -- C++
                "codelldb",
                "cpptools",
                "elixir-ls", -- elixir ls/dap
                "erlang-ls", -- erlang ls/dap
                "gopls", -- go
                "markdown-oxide",
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
                        require("telescope.builtin").lsp_definitions()
                    end, { buffer = true, desc = "Jump to definition" })
                    vim.keymap.set("n", "sgd", function()
                        require("telescope.builtin").lsp_definitions({ jump_type = "vsplit" })
                    end, { buffer = true, desc = "Jump to definition" })
                    vim.keymap.set("n", "tgd", function()
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
        "aznhe21/actions-preview.nvim",
        enabled = load_lsp,
        config = function()
            vim.keymap.set(
                { "v", "n" },
                "<leader>a",
                require("actions-preview").code_actions,
                { desc = "LSP code actions" }
            )
        end,
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
        dependencies = {
            "neovim/nvim-lspconfig",
            "nvim-telescope/telescope.nvim",
            "mfussenegger/nvim-dap-python",
        },
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
