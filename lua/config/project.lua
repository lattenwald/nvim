-- Persists projects as a list of { name = <dir basename>, path = <absolute path> }
-- in projects.yaml, managed through the Snacks.picker UI in M.list_projects().

local M = {}

local projects_file = vim.fn.stdpath("data") .. "/projects.yaml"

-- Memoized; reloaded whenever projects.yaml's mtime changes.
local projects_cache = nil
local cache_mtime = nil

-- Quiet read of projects.yaml. Paths are normalized here so consumers can compare them directly.
function M.get_projects()
    local stat = vim.uv.fs_stat(projects_file)
    local mtime = stat and stat.mtime
    if projects_cache and cache_mtime and mtime and cache_mtime.sec == mtime.sec and cache_mtime.nsec == mtime.nsec then
        return projects_cache
    end

    local parsed = require("config.utils").load_yaml(projects_file, true)
    local result = {}
    if type(parsed) == "table" then
        for _, project in ipairs(parsed) do
            if type(project) == "table" and type(project.path) == "string" then
                local path = vim.fs.normalize(project.path)
                result[#result + 1] = { name = project.name or vim.fs.basename(path), path = path }
            end
        end
    end

    projects_cache = result
    cache_mtime = mtime
    return result
end

-- Private copy of the list, so add/remove don't mutate the cache.
local function read_projects()
    return vim.list_extend({}, M.get_projects())
end

local function write_projects(projects)
    local yaml_ok, yaml = pcall(require, "lyaml")
    if not yaml_ok then
        vim.notify("lyaml not available - project persistence disabled", vim.log.levels.WARN)
        return false
    end

    local ok, err = pcall(function()
        vim.fn.writefile(vim.split(yaml.dump({ projects }), "\n", { trimempty = true }), projects_file)
    end)
    if not ok then
        vim.notify("Failed to save projects: " .. err, vim.log.levels.ERROR)
        return false
    end

    return true
end

function M.add_project()
    local project_root = require("config.utils").find_project_root(vim.uv.cwd())
    if not project_root then
        vim.notify("No project root found.", vim.log.levels.WARN)
        return
    end

    local project_name = vim.fs.basename(project_root)
    local projects = read_projects()

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

    if #projects == 0 then
        vim.notify("No projects found.", vim.log.levels.WARN)
        return
    end

    local items = {}
    for _, project in ipairs(projects) do
        table.insert(items, {
            text = project.name,
            description = project.path,
            file = project.path,
        })
    end

    Snacks.picker({
        items = items,
        actions = {
            confirm = function(picker)
                local item = picker:current()
                if not item then
                    return
                end
                vim.cmd("cd " .. vim.fn.fnameescape(item.file))
                local git_root = require("config.utils").find_project_root(item.file, { ".git" })
                Snacks.picker.files(git_root and { cwd = git_root, hidden = true, ignored = true } or { cwd = item.file })
            end,
            delete_project = function(picker)
                local item = picker:current()
                if not item then
                    return
                end
                vim.ui.select({ "No", "Yes" }, {
                    prompt = "Delete project '" .. item.text .. "'?",
                }, function(choice)
                    if choice == "Yes" and remove_project(item.file) then
                        picker:close()
                        M.list_projects()
                    end
                end)
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

function M.setup()
    vim.api.nvim_create_user_command("ProjectAdd", M.add_project, { desc = "Add the current project" })
    vim.api.nvim_create_user_command("ProjectList", M.list_projects, { desc = "List all projects" })
end

return M
