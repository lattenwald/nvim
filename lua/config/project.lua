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

-- Path to the projects file
local projects_file = vim.fn.stdpath("data") .. "/projects.yaml"

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

-- Function to list projects and allow selection
function M.list_projects()
    local projects = {}
    if uv.fs_stat(projects_file) then
        local file = io.open(projects_file, "r")
        if file then
            local content = file:read("*a")
            if content ~= "" then
                local success, result = pcall(yaml.load, content)
                if success and result then
                    projects = result -- The YAML file contains a direct array of projects
                else
                    vim.notify("Failed to parse projects file", vim.log.levels.ERROR)
                    return
                end
            end
            file:close()
        end
    end

    if #projects == 0 then
        vim.notify("No projects found.", vim.log.levels.WARN)
        return
    end

    local items = {}
    for _, project in ipairs(projects) do
        table.insert(items, {
            text = project.name,
            description = project.path,
            path = project.path,
            file = project.path,
        })
    end

    Snacks.picker({
        items = items,
        layout = "select",
        actions = {
            confirm = function(picker)
                local item = picker:current()
                if item then
                    vim.cmd("cd " .. vim.fn.fnameescape(item.path))
                    vim.defer_fn(function()
                        Snacks.picker.smart()
                    end, 50)
                end
            end,
        },
        keymaps = {
            ["<C-d>"] = function(item)
                -- TODO: Implement project deletion
                vim.notify("Project deletion not implemented yet", vim.log.levels.INFO)
            end,
        },
    })
end

vim.api.nvim_create_user_command("ProjectAdd", function()
    require("config.project").add_project()
end, { desc = "Add the current project" })

vim.api.nvim_create_user_command("ProjectList", function()
    require("config.project").list_projects()
end, { desc = "List all projects" })

return M
