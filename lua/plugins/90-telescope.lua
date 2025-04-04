return {
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "debugloop/telescope-undo.nvim",
        },
        config = function()
            local telescope = require("telescope")
            local open_with_trouble = require("trouble.sources.telescope").open
            local add_to_trouble = require("trouble.sources.telescope").add

            telescope.setup({
                extensions = {
                    undo = {},
                },
                defaults = {
                    path_display = { shorten = { len = 1, exclude = { -1, -2 } } },
                    mappings = {
                        i = {
                            ["<c-cr>"] = "select_tab",
                            ["<s-cr>"] = "select_vertical",
                            ["<c-c>"] = "close",
                            ["<c-t>"] = open_with_trouble,
                            ["<c-s-t>"] = add_to_trouble,
                            ["<s-up>"] = "preview_scrolling_up",
                            ["<s-down>"] = "preview_scrolling_down",
                        },
                        n = {
                            ["<c-cr>"] = "select_tab",
                            ["<s-cr>"] = "select_vertical",
                            ["<esc>"] = "close",
                            ["q"] = "close",
                            ["<c-t>"] = open_with_trouble,
                            ["<c-s-t>"] = add_to_trouble,
                            ["<s-up>"] = "preview_scrolling_up",
                            ["<s-down>"] = "preview_scrolling_down",
                        },
                    },
                },
                pickers = {
                    buffers = {
                        mappings = {
                            i = {
                                ["<delete>"] = "delete_buffer",
                            },
                            n = {
                                ["<delete>"] = "delete_buffer",
                            },
                        },
                    },
                },
            })

            local builtin = require("telescope.builtin")

            vim.keymap.set("n", "<leader>i", function()
                if require("util").lsp_active() then
                    builtin.lsp_document_symbols()
                else
                    builtin.treesitter()
                end
            end, { desc = "Jump to document symbol" })
            vim.keymap.set("n", "<leader>I", builtin.treesitter, { desc = "Jump to treesitter symbol" })

            vim.keymap.set("n", "<leader>b", function()
                require("telescope.builtin").buffers({
                    sort_lastused = true,
                    sort_mru = true,
                })
            end, { desc = "Jump to buffers" })

            local project_dir = function()
                local dir = vim.fs.find(".git", {
                    upward = true,
                    stop = vim.loop.os_homedir(),
                    path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
                })[1]
                if not dir then
                    dir = vim.fs.find("Cargo.toml", {
                        upward = true,
                        stop = vim.loop.os_homedir(),
                        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
                    })[1]
                end
                return vim.fs.dirname(dir)
            end

            vim.keymap.set("n", "<leader>f", builtin.git_files, { desc = "Jump to file tracked by git" })
            vim.keymap.set("n", "<leader>F", function()
                builtin.find_files({ cwd = project_dir() })
            end, { desc = "Jump to file" })
            vim.keymap.set("n", "<leader>C", builtin.git_commits, { desc = "Jump to git commit" })
            vim.keymap.set("n", "<leader>r", function()
                builtin.live_grep({ cwd = project_dir() })
            end, { desc = "Live grep with rg" })
            -- vim.keymap.set('n', '<leader><C-r>', function() require("telescope.builtin").live_grep({search_dirs={vim.fn.expand("%:p")}}) end, {desc = 'Live grep with rg in current file'})
            vim.keymap.set("n", "<f3>", function()
                builtin.grep_string({ glob_pattern = vim.fn.expand("%") })
            end, { desc = "Find string under cursor in current file" })

            vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>", { desc = "undo tree" })
        end,
    },
    {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").load_extension("file_browser")
        end,
    },
    {
        "nvim-telescope/telescope-project.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-file-browser.nvim",
        },
        config = function()
            require("telescope").load_extension("project")
            vim.keymap.set("n", "<leader>p", function()
                require("telescope").extensions.project.project({ display = "full" })
            end, { desc = "Projects" })
        end,
    },
    {
        "isak102/telescope-git-file-history.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim",
            "tpope/vim-fugitive",
        },
        config = function()
            require("telescope").load_extension("git_file_history")
        end,
    },
}
