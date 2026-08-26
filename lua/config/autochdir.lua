-- Custom autochdir implementation with worktree support while avoiding submodules
local M = {}

local last_dir = nil

local function auto_chdir()
    local current_file = vim.api.nvim_buf_get_name(0)

    -- Skip for empty buffers, special buffers, and during startup
    if current_file == "" or vim.bo.buftype ~= "" or vim.v.vim_did_enter == 0 then
        return
    end

    local utils = require("config.utils")
    local project_root = utils.find_project_root(current_file)

    if project_root and project_root ~= last_dir then
        vim.cmd("cd " .. vim.fn.fnameescape(project_root))
        last_dir = project_root

        -- No .git means a generic project (e.g. a project-root marker)
        local root_type = utils.get_git_type(project_root .. "/.git") or "project"
        local root_name = vim.fs.basename(project_root)
        vim.notify(string.format("📂 %s (%s)", root_name, root_type), vim.log.levels.INFO)
    end
end

function M.setup()
    vim.api.nvim_create_augroup("CustomAutochdir", { clear = true })
    vim.api.nvim_create_autocmd("BufEnter", {
        group = "CustomAutochdir",
        callback = auto_chdir,
        desc = "Auto change directory to project root (supports worktrees, ignores submodules)",
    })
end

return M
