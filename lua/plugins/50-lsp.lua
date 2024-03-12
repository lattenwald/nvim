return {
    {
        'williamboman/mason.nvim',
        opts = {},
    },
    {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        opts = {
            ensure_installed = {
                'codelldb', -- rust dap
                'stylua', -- lua formatter
                'beautysh', -- sh/zsh/bash/etc formatter
                'shellcheck', -- bash linter
                'prettierd', -- html/json/css/etc formatter
                'ansible-language-server', 'ansible-lint',
                'xmlformatter',
                'erlang-ls', -- erlang ls/dap
                'elixir-ls', -- elixir ls/dap
                'phpactor', -- PHP LSP
                'texlab', -- LaTeX LSP
                'pyright', -- Python LSP
            },
            auto_update = true,
            run_on_start = true,
        },
    },
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup()

            local lspconfig = require'lspconfig'
            local cmp_capabilities = require'cmp_nvim_lsp'.default_capabilities()

            -- TODO incorporate current code location in statusline
            lspconfig.erlangls.setup{
                capabilities = cmp_capabilities
            }
            lspconfig.elixirls.setup{
                capabilities = cmp_capabilities
            }
            -- lspconfig.rust_analyzer.setup{
            --     capabilities = cmp_capabilities
            -- }
            lspconfig.ansiblels.setup{
                capabilities = cmp_capabilities
            }

            lspconfig.phpactor.setup{
                on_attach = on_attach,
                init_options = {
                    ["language_server_phpstan.enabled"] = false,
                    ["language_server_psalm.enabled"] = false,
                }
            }

            lspconfig.pyright.setup{
                capabilities = cmp_capabilities
            }

            lspconfig.texlab.setup{}

            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('UserLspConfig', {}),
                callback = function(ev)
                    print("LS attached buf=" .. ev.buf .. " client=" .. vim.lsp.get_client_by_id(ev.data.client_id).name)

                    local buf = ev.buf
                    local opts = { buffer = buf }

                    vim.keymap.set('n', 'gr', require'telescope.builtin'.lsp_references, {buffer = buf, desc = 'Jump to reference'})
                    vim.keymap.set('n', 'gd', function() require'telescope.builtin'.lsp_definitions{jump_type = "tab"} end, {buffer = buf, desc = 'Jump to definition'})
                    vim.keymap.set('n', 'gi', require'telescope.builtin'.lsp_implementations, {buffer = buf, desc = 'Jump to implementation'})

                    vim.keymap.set('n', '<leader>d', '<cmd>Lspsaga hover_doc<cr>', {desc = "LSP hover doc", buffer = buf})
                    vim.keymap.set('n', 'gD', '<cmd>Lspsaga peek_definition<cr>', {desc = "LSP peek definition", buffer = buf})
                    vim.keymap.set('n', 'gT', '<cmd>Lspsaga peek_type_definition<cr>', {desc = "LSP peek type definition", buffer = buf})
                    vim.keymap.set('n', '<leader>v', '<cmd>Lspsaga outline<cr>', {desc = "LSP outline", buffer = buf})
                    vim.keymap.set('n', '<leader>Q', '<cmd>Lspsaga show_workspace_diagnostics<cr>', {desc = "LSP diagnostics", buffer = buf})

                    vim.keymap.set('n', '<leader>n', function() return ':IncRename ' .. vim.fn.expand('<cword>') end, {buffer = buf, expr = true, desc = 'LSP rename symbol'})

                    vim.keymap.set('n', '<leader>s', function()
                        vim.lsp.buf.format { async = true }
                    end, {buffer = buf, desc = 'Format buffer'})


                    vim.keymap.set({'n', 'v'}, '<leader>a', require'code_action_menu'.open_code_action_menu, {desc = 'LSP code action', buffer = buf})
                end,
            })
        end
    },
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'theHamsta/nvim-dap-virtual-text', 'rcarriga/nvim-dap-ui', 'nvim-telescope/telescope-dap.nvim',
            'mfussenegger/nvim-dap-python',
            'jbyuki/one-small-step-for-vimkind', -- LUA DAP adapter
        },
        config = function()
            local dap = require'dap'
            local dapui = require'dapui'
            local dap_ui_widgets = require'dap.ui.widgets'

            dapui.setup{}
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            vim.keymap.set('n', '<F5>',  dap.continue, {desc = 'DAP continue'})
            vim.keymap.set('n', '<F10>', dap.step_over, {desc = 'DAP step over'})
            vim.keymap.set('n', '<F11>', dap.step_into, {desc = 'DAP step into'})
            vim.keymap.set('n', '<F12>', dap.step_out, {desc = 'DAP step out'})
            vim.keymap.set('n', '<Leader>eb', dap.toggle_breakpoint, {desc = 'DAP toggle breakpoint'})
            vim.keymap.set('n', '<Leader>eB', dap.set_breakpoint, {desc = 'DAP set breakpoint'})
            vim.keymap.set('n', '<Leader>el', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, {desc = 'DAP set log breakpoint'})
            vim.keymap.set('n', '<Leader>er', dap.repl.open, {desc = 'DAP open repl'})
            vim.keymap.set('n', '<Leader>el', dap.run_last, {desc = 'DAP run last'})
            vim.keymap.set({'n', 'v'}, '<Leader>eh', dap_ui_widgets.hover, {desc = 'DAP UI hover'})
            vim.keymap.set({'n', 'v'}, '<Leader>ep', dap_ui_widgets.preview, {desc = 'DAP preview'})
            vim.keymap.set('n', '<Leader>ef', function()
                dap_ui_widgets.centered_float(dap_ui_widgets.frames)
            end, {desc = 'DAP UI frames'})
            vim.keymap.set('n', '<Leader>es', function()
                dap_ui_widgets.centered_float(dap_ui_widgets.scopes)
            end, {desc = 'DAP UI scopes'})
        end,
    },
    {
        'jose-elias-alvarez/null-ls.nvim',
        -- enabled = false,
        config = function()
            local null_ls = require'null-ls'

            opts = {
                sources = {
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.formatting.beautysh,
                    null_ls.builtins.code_actions.shellcheck,
                    null_ls.builtins.formatting.prettierd,
                    null_ls.builtins.diagnostics.ansiblelint,
                    null_ls.builtins.formatting.xmlformat,
                }
            }

            null_ls.setup(opts)
        end,
    },
    {
        'mrcjkb/rustaceanvim',
        -- enabled = false,
        -- ft = 'rust',
    },
    {
        'simrat39/rust-tools.nvim',
        enabled = false,
        ft = 'rust',
        config = function()
            local rt = require'rust-tools'
            local dap = require'dap'
            local codelldb_root = require'mason-registry'.get_package("codelldb"):get_install_path() .. "/extension/"
            local codelldb_path = codelldb_root .. "adapter/codelldb"
            local liblldb_path = codelldb_root .. "lldb/lib/liblldb.so"

            opts = {
                hover_actions = {
                    auto_focus = true,
                },
                server = {
                    settings = {
                        ["rust-analyzer"] = {
                            checkOnSave = {
                                command = "clippy"
                            },
                            procMacro = {
                                enable = true,
                            },
                        },
                    },
                    on_attach = function(_, bufnr)
                        print("rust LS attached")
                        vim.keymap.set('n', '<leader>R', rt.workspace_refresh.reload_workspace, {desc = 'Reload workspace', buffer = bufnr})
                        vim.keymap.set("n", "<leader>A", rt.hover_actions.hover_actions, {desc = 'Rust hover action', buffer = bufnr})
                        vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, {desc = 'Rust code action', buffer = bufnr})
                        vim.keymap.set("n", "<Leader>D", rt.debuggables.debuggables, {desc = 'Rust debuggables', buffer = bufnr})
                        vim.keymap.set("n", "<Leader>R", rt.runnables.runnables, {desc = 'Rust runnables', buffer = bufnr})
                    end,
                },
                dap = { adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path) },
            }
            rt.setup(opts)

            dap.adapters.rust = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
            dap.configurations.rust = {
                {
                    type = "rust",
                    name = "Launch",
                    request = "launch",
                    cwd = '${workspaceFolder}',
                    program = function()
                        local _, cwd = next(vim.lsp.buf.list_workspace_folders())
                        return vim.fn.input('Path to executable: ', cwd .. '/target/debug', 'file')
                    end,
                    stopOnEntry = false,
                    args = function()
                        local args_str = vim.fn.input('Program arguments: ')
                        return vim.fn.split(args_str)
                    end,
                    runInTerminal = false,
                },
            }
        end,
    },
    {
        'weilbith/nvim-code-action-menu',
        cmd = {'CodeActionMenu'},
        keys = {'<leader>a'},
    },
    {
        'kosayoda/nvim-lightbulb',
        enabled = false,
        opts = {
            autocmd = {enabled = true}
        }
    },
    {
        'j-hui/fidget.nvim',
        enabled = false,
        opts = {
            text = {
                spinner = 'clock'
            }
        },
    },
    {
        'smjonas/inc-rename.nvim',
        opts = {},
    },
    {
        'nvimdev/lspsaga.nvim',
        version = nil,
        opts = {
            outline = {
                keys = {
                    toggle_or_jump = "<cr>"
                }
            },
            lightbulb = {
                enable = false,
            }
        },
    },
}
