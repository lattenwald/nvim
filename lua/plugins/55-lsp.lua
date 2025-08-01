return {
    {
        "mason-org/mason.nvim",
        opts = {},
    },
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {},
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(ev)
                    local bufnr = ev.buf
                    print("LS attached buf=" .. bufnr .. " client=" .. vim.lsp.get_client_by_id(ev.data.client_id).name)
                    vim.keymap.set("n", "<leader>n", function()
                        return ":IncRename " .. vim.fn.expand("<cword>")
                    end, { buffer = bufnr, expr = true, desc = "LSP rename symbol" })
                    vim.keymap.set("n", "]g", function()
                        vim.diagnostic.goto_next()
                    end, { buffer = bufnr, silent = true, desc = "Go to next diagnostic" })
                    vim.keymap.set("n", "[g", function()
                        vim.diagnostic.goto_prev()
                    end, { buffer = bufnr, silent = true, desc = "Go to previous diagnostic" })
                    vim.keymap.set("n", "<leader>d", function()
                        vim.lsp.buf.hover()
                    end, { buffer = bufnr, desc = "LSP Hover" })
                    vim.keymap.set("n", "<leader>a", function()
                        vim.lsp.buf.code_action()
                    end, { buffer = bufnr, desc = "LSP Code Action" })
                    vim.keymap.set("n", "<leader>D", function()
                        vim.diagnostic.open_float()
                    end, { buffer = bufnr, desc = "Show diagnostic" })
                end,
            })
        end,
    },
    {
        "SmiteshP/nvim-navic",
        opts = {
            auto_attach = true,
        },
    },
    {
        "stevearc/conform.nvim",

        config = function()
            require("conform").formatters.injected = {
                ignore_errors = false,
                lang_to_ft = {
                    bash = "sh",
                },
                lang_to_ext = {
                    bash = "sh",
                    c_sharp = "cs",
                    elixir = "ex",
                    javascript = "js",
                    julia = "jl",
                    latex = "tex",
                    markdown = "md",
                    python = "py",
                    ruby = "rb",
                    rust = "rs",
                    teal = "tl",
                    typescript = "ts",
                    jinja = "jinja",
                    html = "html",
                },
            }
            vim.keymap.set({ "n", "v" }, "<leader>s", function()
                require("conform").format({ lsp_fallback = true })
            end, { desc = "Format" })
        end,
    },
    {
        "rmagatti/goto-preview",
        dependencies = { "rmagatti/logger.nvim" },
        event = "LspAttach",
        opts = {
            references = {
                provider = "snacks",
            },
        },
        config = function(_, opts)
            local gpd = require("goto-preview")
            gpd.setup(opts)

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                -- stylua: ignore
                callback = function(ev)
                    local bufnr = ev.buf
                    vim.keymap.set("n", "gpd", function() gpd.goto_preview_definition() end, { desc = "Preview definition", buffer = bufnr })
                    vim.keymap.set("n", "gpt", function() gpd.goto_preview_type_definition() end, { desc = "Preview type", buffer = bufnr })
                    vim.keymap.set("n", "gpi", function() gpd.goto_preview_implementation() end, { desc = "Preview implementation", buffer = bufnr })
                    vim.keymap.set("n", "gpD", function() gpd.goto_preview_declaration() end, { desc = "Preview declaration", buffer = bufnr })
                    vim.keymap.set("n", "gpr", function() gpd.goto_preview_references() end, { desc = "Preview references", buffer = bufnr })
                end,
            })
        end,
    },
}

