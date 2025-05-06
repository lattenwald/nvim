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

-- Function to remove a project
local function remove_project(project_path)
    local projects = {}
    if uv.fs_stat(projects_file) then
        local file = io.open(projects_file, "r")
        if file then
            local content = file:read("*a")
            if content ~= "" then
                local success, result = pcall(yaml.load, content)
                if success and result then
                    -- Ensure we have an array of projects
                    if type(result) == "table" then
                        if #result > 0 then
                            projects = result
                        else
                            -- If it's an empty table, it might be a single project
                            if result.name and result.path then
                                projects = { result }
                            end
                        end
                    end
                else
                    vim.notify("Failed to parse projects file", vim.log.levels.ERROR)
                    return false
                end
            end
            file:close()
        end
    end

    -- Find and remove the project
    local found = false
    for i, project in ipairs(projects) do
        if project.path == project_path then
            table.remove(projects, i)
            found = true
            break
        end
    end

    if not found then
        vim.notify("Project not found", vim.log.levels.WARN)
        return false
    end

    -- Save the updated projects
    local file = io.open(projects_file, "w")
    if file then
        local success, err = pcall(function()
            -- Ensure we write an array of projects
            file:write("---\n")
            for _, project in ipairs(projects) do
                file:write("- name: " .. project.name .. "\n")
                file:write("  path: " .. project.path .. "\n")
            end
        end)
        if not success then
            vim.notify("Failed to save projects: " .. err, vim.log.levels.ERROR)
            file:close()
            return false
        end
        file:close()
        vim.notify("Project removed successfully", vim.log.levels.INFO)
        return true
    else
        vim.notify("Failed to open projects file for writing", vim.log.levels.ERROR)
        return false
    end
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
                    -- Ensure we have an array of projects
                    if type(result) == "table" then
                        if #result > 0 then
                            projects = result
                        else
                            -- If it's an empty table, it might be a single project
                            if result.name and result.path then
                                projects = { result }
                            end
                        end
                    end
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
                    Snacks.picker.smart()
                end
            end,
            delete_project = function(picker)
                local item = picker:current()
                if item then
                    if remove_project(item.path) then
                        -- Close the picker and reopen it to refresh the list
                        picker:close()
                        M.list_projects()
                    end
                end
            end,
            add_current_project = function(picker)
                picker:close()
                M.add_project()
                M.list_projects()
            end,
        },
        win = {
            input = {
                keys = {
                    ["<C-d>"] = { "delete_project", mode = { "n", "i" } },
                    ["<C-a>"] = { "add_current_project", mode = { "n", "i" } },
                    ["a"] = { "add_current_project", mode = { "n" } },
                    ["<Delete>"] = { "delete_project", mode = { "n" } },
                },
            },
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
