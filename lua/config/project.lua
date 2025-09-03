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
local projects_file = vim.fn.stdpath("data") .. "/projects.yaml" -- Path to store project data

-- Function to find the project root
local function find_project_root()
    local markers = M.config.project_markers or { ".git", "Cargo.toml", "pyproject.toml", "rebar.config", "project-root" }
    local start_dir = uv.cwd()
    local stop_dir = vim.loop.os_homedir()

    local current_dir = start_dir
    while current_dir do
        for _, marker in ipairs(markers) do
            local marker_path = current_dir .. "/" .. marker
            -- vim.loop.fs_stat is a sync call that returns nil if the path doesn't exist.
            -- This works for both files (e.g., Cargo.toml) and directories (e.g., .git).
            if vim.loop.fs_stat(marker_path) then
                return current_dir -- Found the directory containing the marker.
            end
        end

        -- Stop if we have searched the stop_dir and found nothing.
        if current_dir == stop_dir then
            return nil
        end

        local parent_dir = vim.fn.fnamemodify(current_dir, ":h")

        -- Stop if we have reached the filesystem root.
        if parent_dir == current_dir or not parent_dir or parent_dir == "" then
            return nil
        end

        current_dir = parent_dir
    end

    return nil
end

-- Function to read projects from YAML file
local function read_projects()
    local ok, result = pcall(require("config.utils").load_yaml, projects_file)
    if not ok or type(result) ~= "table" then
        vim.notify("Failed to parse projects file: " .. (result or "unknown error"), vim.log.levels.ERROR)
        return {}
    end
    return result
end

-- Function to write projects to YAML file using lyaml
local function write_projects(projects)
    local ok, err = pcall(function()
        local yaml_content = yaml.dump({ projects })
        local file = assert(io.open(projects_file, "w"))
        file:write(yaml_content)
        file:close()
    end)
    if not ok then
        vim.notify("Failed to save projects: " .. err, vim.log.levels.ERROR)
        return false
    end
    return true
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
            vim.notify(string.format("%s - project already exists.", project_root), vim.log.levels.INFO)
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
        actions = {
            confirm = function(picker)
                local item = picker:current()
                if item then
                    local project_dir = vim.fn.fnameescape(item.path)
                    vim.cmd("cd " .. project_dir)
                    local git_root = vim.fs.find(".git", {
                        path = project_dir,
                        upward = true,
                    })[1]

                    if git_root then
                        local cwd = vim.fn.fnamemodify(git_root, ":h")
                        Snacks.picker.files({
                            cwd = cwd,
                            hidden = true,
                            ignored = true,
                        })
                    else
                        Snacks.picker.files({ cwd = project_dir })
                    end
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
                    ["<Del>"] = { "delete_project", mode = { "n" } },
                },
            },
        },
    })
end

function M.setup(config)
    M.config = vim.tbl_deep_extend("force", {
        project_markers = { ".git", "project-root" },
    }, config or {})

    vim.api.nvim_create_user_command("ProjectAdd", function()
        require("config.project").add_project()
    end, { desc = "Add the current project" })

    vim.api.nvim_create_user_command("ProjectList", function()
        require("config.project").list_projects()
    end, { desc = "List all projects" })
end

return M
