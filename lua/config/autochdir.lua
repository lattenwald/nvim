-- Custom autochdir implementation with worktree support while avoiding submodules
local M = {}

local last_dir = nil

local function get_root_type(root_path)
    local git_path = root_path .. "/.git"
    local git_type = require("config.utils").get_git_type(git_path)

    -- If no .git found, it's a generic project (e.g., has project-root marker)
    return git_type or "project"
end

local function auto_chdir()
    local current_file = vim.api.nvim_buf_get_name(0)

    -- Skip for empty buffers, special buffers, and during startup
    if current_file == "" or vim.bo.buftype ~= "" or vim.v.vim_did_enter == 0 then
        return
    end

    local project_root = require("config.utils").find_project_root(current_file, { ".git", "project-root" })

    if project_root and project_root ~= last_dir then
        vim.cmd("cd " .. vim.fn.fnameescape(project_root))
        last_dir = project_root

        local root_type = get_root_type(project_root)
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
