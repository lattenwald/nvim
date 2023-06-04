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
            local lspconfig = require'lspconfig'
            local cmp_capabilities = require'cmp_nvim_lsp'.default_capabilities()
            -- TODO incorporate current code location in statusline
            lspconfig.erlangls.setup{
                capabilities = cmp_capabilities
            }
            -- lspconfig.rust_analyzer.setup{
            --     capabilities = cmp_capabilities
            -- }
            lspconfig.ansiblels.setup{
                capabilities = cmp_capabilities
            }
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

            local codelldb_root = require'mason-registry'.get_package("codelldb"):get_install_path() .. "/extension/"
            local codelldb_path = codelldb_root .. "adapter/codelldb"
            local liblldb_path = codelldb_root .. "lldb/lib/liblldb.so"

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
        'jose-elias-alvarez/null-ls.nvim',
        config = function()
            local null_ls = require'null-ls'

            opts = {
                sources = {
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.formatting.beautysh,
                    null_ls.builtins.code_actions.shellcheck,
                    null_ls.builtins.formatting.prettierd,
                    null_ls.builtins.diagnostics.ansiblelint,
                }
            }

            null_ls.setup(opts)
        end,
    },
    {
        'simrat39/rust-tools.nvim',
        config = function()
            local lldb_path = '/usr/lib/codelldb'
            local rt = require'rust-tools'
            opts = {
                server = {
                    settings = {
                        ["rust-analyzer"] = {
                            checkOnSave = {
                                command = "clippy"
                            },
                        },
                    },
                },
                dap = {
                    adapter = require'rust-tools.dap'.get_codelldb_adapter(
                        lldb_path .. '/adapter/codelldb',
                        lldb_path .. '/lldb/lib/liblldb' )
                }
            }

            rt.setup(opts)
        end,
    },
    {
        'weilbith/nvim-code-action-menu',
        cmd = 'CodeActionMenu',
        config = function()
            vim.keymap.set('n', '<leader>a', require'code_action_menu'.open_code_action_menu, {desc = 'LSP code action'})
            vim.keymap.set('v', '<leader>a', require'code_action_menu'.open_code_action_menu, {desc = 'LSP code action'})
        end,
    },
    {
        'kosayoda/nvim-lightbulb',
        opts = {
            autocmd = {enabled = true}
        }
    },
    {
        'j-hui/fidget.nvim',
        opts = {
            text = {
                spinner = 'clock'
            }
        },
    }
}
