-- This lua file is a module for working with projects, implementing following logic:
-- Projects are stored in yaml file projects.yaml, format is:
-- - name: project name
--   path: path
-- project name is project directory basename, path is absolute path to project
--
-- There are following functions:
-- 1. function to read this file and display projects in Snacks.picker. On selecting particular
--    project directory is changed to this project dir and then Snacks picker files selector is shown
-- 2. function to add current project. Project is identified by presence of .git, Cargo.toml, or pyproject.toml
--    in current or nearest parent directory. That directory is project root.
-- 3. function to remove project, selected in Snacks picker, bound to <C-d> or <Delete>

local M = {}

local uv = vim.loop
local yaml = require("lyaml")

-- Function to find the project root
local function find_project_root()
    local markers = { ".git", "Cargo.toml", "pyproject.toml" }
    local cwd = uv.cwd()
    while cwd do
        for _, marker in ipairs(markers) do
            if uv.fs_stat(cwd .. "/" .. marker) then
                return cwd
            end
        end
        cwd = cwd:match('(.*)/[^"]+')
    end
    return nil
end

-- Function to add the current project
function M.add_project()
    local project_root = find_project_root()
    if not project_root then
        vim.notify("No project root found.", vim.log.levels.WARN)
        return
    end

    local project_name = project_root:match(".*/(.*)")
    local projects_file = vim.fn.stdpath("data") .. "/projects.yaml"

    local projects = {}
    if uv.fs_stat(projects_file) then
        local file = io.open(projects_file, "r")
        if file then
            local content = file:read("*a")
            if content == "" then
                projects = {}
            else
                projects = yaml.load(content) or {}
            end
            file:close()
        end
    end

    for _, project in ipairs(projects) do
        if project.path == project_root then
            vim.notify("Project already exists.", vim.log.levels.INFO)
            return
        end
    end

    local project_exists = false
    for _, project in ipairs(projects) do
        if project.path == project_root then
            project_exists = true
            break
        end
    end

    if not project_exists then
        table.insert(projects, { name = project_name, path = project_root })
    end

    local file = io.open(projects_file, "w")
    if file then
        local success, err = pcall(function()
            file:write(yaml.dump({ projects }))
        end)
        if not success then
            vim.notify("Failed to save projects: " .. err, vim.log.levels.ERROR)
        end
        file:close()
    else
        vim.notify("Failed to open projects file for writing.", vim.log.levels.ERROR)
    end

    vim.notify("Project added: " .. project_name, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("ProjectAdd", function()
    require("config.project").add_project()
end, { desc = "Add the current project" })

return M
