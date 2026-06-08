-- Persists projects as a list of { name = <dir basename>, path = <absolute path> }
-- in projects.yaml, managed through the Snacks.picker UI in M.list_projects().

local M = {}

local uv = vim.loop
local yaml_ok, yaml = pcall(require, "lyaml")
if not yaml_ok then
    vim.notify("lyaml not available - project persistence disabled", vim.log.levels.WARN)
end

local projects_file = vim.fn.stdpath("data") .. "/projects.yaml"

-- Memoized; reloaded whenever projects.yaml's mtime changes.
local projects_cache = nil
local cache_mtime = nil

local function file_mtime()
    local stat = uv.fs_stat(projects_file)
    return stat and stat.mtime
end

local function mtime_unchanged(mtime)
    return cache_mtime and mtime and cache_mtime.sec == mtime.sec and cache_mtime.nsec == mtime.nsec
end

-- Quiet read of projects.yaml.
function M.get_projects()
    if not yaml_ok then
        return {}
    end

    local mtime = file_mtime()
    if projects_cache and mtime_unchanged(mtime) then
        return projects_cache
    end

    local result = {}
    local file = io.open(projects_file, "r")
    if file then
        local content = file:read("*a")
        file:close()
        if content ~= "" then
            local ok, parsed = pcall(yaml.load, content)
            if ok and type(parsed) == "table" then
                result = parsed
            end
        end
    end

    projects_cache = result
    cache_mtime = mtime
    return result
end

-- Returns a private copy.
local function read_projects()
    return vim.list_extend({}, M.get_projects())
end

local function write_projects(projects)
    if not yaml_ok then
        return false
    end
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

function M.add_project()
    local project_root = require("config.utils").find_project_root(vim.uv.cwd(), M.config.project_markers)
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

local function remove_project(project_path)
    local projects = read_projects()
    if not projects then
        return false
    end

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
                    local git_root = require("config.utils").find_project_root(project_dir, { ".git" })

                    if git_root then
                        Snacks.picker.files({
                            cwd = git_root,
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
