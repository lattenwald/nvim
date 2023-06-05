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

            local codelldb_root = require'mason-registry'.get_package("codelldb"):get_install_path() .. "/extension/"
            local codelldb_path = codelldb_root .. "adapter/codelldb"
            local liblldb_path = codelldb_root .. "lldb/lib/liblldb.so"

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
        ft = 'rust',
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
                    on_attach = function(_, bufnr)
                        vim.keymap.set('n', '<leader>R', rt.workspace_refresh.reload_workspace, {desc = 'Reload workspace', buffer = bufnr})
                    end,
                },
                dap = {
                    adapter = require'rust-tools.dap'.get_codelldb_adapter(
                        lldb_path .. '/adapter/codelldb',
                        lldb_path .. '/lldb/lib/liblldb' )
                },
            }
            rt.setup(opts)

            local dap = require'dap'
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
        config = function()
            local code_action_menu = require'code_action_menu'
            vim.keymap.set({'n', 'v'}, '<leader>a', code_action_menu.open_code_action_menu, {desc = 'LSP code action'})
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
