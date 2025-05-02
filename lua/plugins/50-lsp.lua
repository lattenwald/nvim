return {
    {
        "williamboman/mason.nvim",
        opts = {},
    },
    {
        "williamboman/mason-lspconfig.nvim",
        opts = {
            automatic_installation = true,
        },
        config = function(_, opts)
            require("mason-lspconfig").setup(opts)
            require("mason-lspconfig").setup_handlers({
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup({})
                end,
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    print("LS attached buf=" .. ev.buf .. " client=" .. vim.lsp.get_client_by_id(ev.data.client_id).name)
                    vim.keymap.set("n", "<leader>n", function()
                        return ":IncRename " .. vim.fn.expand("<cword>")
                    end, { buffer = true, expr = true, desc = "LSP rename symbol" })
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
                    vim.keymap.set("n", "gpd", function() gpd.goto_preview_definition() end, { desc = "Preview definition"})
                    vim.keymap.set("n", "gpt", function() gpd.goto_preview_type_definition() end, { desc = "Preview type"})
                    vim.keymap.set("n", "gpi", function() gpd.goto_preview_implementation() end, { desc = "Preview implementation"})
                    vim.keymap.set("n", "gpD", function() gpd.goto_preview_declaration() end, { desc = "Preview declaration"})
                    vim.keymap.set("n", "gpr", function() gpd.goto_preview_references() end, { desc = "Preview references"})
                end,
            })
        end,
    },
}
