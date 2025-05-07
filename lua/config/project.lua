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
    local markers = { ".git", "Cargo.toml", "pyproject.toml", "rebar.config" }
    local cwd = vim.fs.find(markers, {
        upward = true,
        stop = vim.loop.os_homedir(),
        path = uv.cwd(),
    })[1]
    local project_root = vim.fs.dirname(cwd)
    return project_root
end

-- Function to read projects from YAML file
local function read_projects()
    local projects = {}
    if uv.fs_stat(projects_file) then
        local file = io.open(projects_file, "r")
        if file then
            local content = file:read("*a")
            if content ~= "" then
                local success, result = pcall(yaml.load, content)
                if success and result then
                    if type(result) == "table" then
                        if #result > 0 then
                            projects = result
                        else
                            if result.name and result.path then
                                projects = { result }
                            end
                        end
                    end
                else
                    vim.notify("Failed to parse projects file", vim.log.levels.ERROR)
                    return nil
                end
            end
            file:close()
        end
    end
    return projects
end

-- Function to write projects to YAML file
local function write_projects(projects)
    local file = io.open(projects_file, "w")
    if file then
        local success, err = pcall(function()
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
        return true
    else
        vim.notify("Failed to open projects file for writing", vim.log.levels.ERROR)
        return false
    end
end

-- Function to add the current project
function M.add_project()
    local project_root = find_project_root()
    if not project_root then
        vim.notify("No project root found.", vim.log.levels.WARN)
        return
    end

    local project_name = project_root:match(".*/(.*)")
    local projects = read_projects() or {}

    for _, project in ipairs(projects) do
        if project.path == project_root then
            vim.notify("Project already exists.", vim.log.levels.INFO)
            return
        end
    end

    table.insert(projects, { name = project_name, path = project_root })
    if write_projects(projects) then
        vim.notify("Project added: " .. project_name, vim.log.levels.INFO)
    end
end

-- Function to remove a project
local function remove_project(project_path)
    local projects = read_projects()
    if not projects then
        return false
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

    if write_projects(projects) then
        vim.notify("Project removed successfully", vim.log.levels.INFO)
        return true
    end
    return false
end

-- Function to list projects and allow selection
function M.list_projects()
    local projects = read_projects()
    if not projects then
        return
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
                    vim.ui.select({ "No", "Yes" }, {
                        prompt = "Delete project '" .. item.text .. "'?",
                        format_item = function(choice)
                            return choice
                        end,
                    }, function(choice)
                        if choice == "Yes" then
                            if remove_project(item.path) then
                                -- Close the picker and reopen it to refresh the list
                                picker:close()
                                M.list_projects()
                            end
                        end
                    end)
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
                    ["d"] = { "delete_project", mode = { "n" } },
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
