-- Custom autochdir implementation with submodule support
local M = {}

local last_dir = nil

-- Function to change directory to project root
local function auto_chdir()
    local current_file = vim.api.nvim_buf_get_name(0)

    -- Skip for empty buffers, special buffers, and during startup
    if current_file == "" or vim.bo.buftype ~= "" or vim.v.vim_did_enter == 0 then
        return
    end

    local project_root =
        require("config.utils").find_project_root(current_file, { ".git", "project-root" })

    if project_root and project_root ~= last_dir then
        vim.cmd("cd " .. vim.fn.fnameescape(project_root))
        last_dir = project_root
    end
end

function M.setup()
    -- Set up autocommand for automatic directory changing
    vim.api.nvim_create_augroup("CustomAutochdir", { clear = true })
    vim.api.nvim_create_autocmd("BufEnter", {
        group = "CustomAutochdir",
        callback = auto_chdir,
        desc = "Auto change directory to project root (ignoring submodules)",
    })
end

return M
