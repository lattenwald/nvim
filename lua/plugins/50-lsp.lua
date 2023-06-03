return {
    {
        'williamboman/mason.nvim',
        opts = {},
    },
    {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        opts = {
            ensure_installed = {'codelldb', 'stylua', 'beautysh', 'shellcheck', 'prettierd'},
            auto_update = true,
            run_on_start = true,
        },
    },
    {
        'neovim/nvim-lspconfig',
        priority = 100,
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',
        },
        config = function()
            local lspconfig = require'lspconfig'
            local cmp_capabilities = require'cmp_nvim_lsp'.default_capabilities()
            -- TODO incorporate current location in statusline
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
                    -- args = {},
                    args = function()
                        local args_str = vim.fn.input('Arguments: ')
                        local args = {}
                        for str in string.gmatch(args_str, "([^%s]+)") do
                            table.insert(args, str)
                        end
                        return args
                    end,
                    runInTerminal = false,
                },
            }
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
        event = 'VeryLazy',
        cmd = 'CodeActionMenu',
        config = function()
            vim.keymap.set('n', '<leader>a', require'code_action_menu'.open_code_action_menu, {desc = 'LSP code action'})
            vim.keymap.set('v', '<leader>a', require'code_action_menu'.open_code_action_menu, {desc = 'LSP code action'})
        end,
    },
    {
        'kosayoda/nvim-lightbulb',
        event = 'VeryLazy',
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
