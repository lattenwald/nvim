local M = {}

-- Cache for root finding to prevent redundant filesystem searches
local root_cache = {}

-- Safe root finding with boundaries, caching, and submodule support
function M.find_project_root(start_path, patterns, opts)
    opts = opts or {}
    local ignore_submodules = opts.ignore_submodules or false

    patterns = patterns or { ".git", "project-root" }
    -- Add ignore_submodules to cache key to differentiate results
    local cache_key = start_path .. ":" .. table.concat(patterns, ",") .. ":sub=" .. tostring(ignore_submodules)

    if root_cache[cache_key] ~= nil then
        return root_cache[cache_key]
    end

    local stop_dirs = { vim.fn.expand("~"), "/" }

    -- Ensure we start searching from a directory
    local start_dir
    local start_stat = vim.loop.fs_stat(start_path)
    if start_stat and start_stat.type == "directory" then
        start_dir = start_path
    else
        start_dir = vim.fs.dirname(start_path)
    end

    local current_path = vim.fs.normalize(start_dir)
    local root = nil

    while current_path and not vim.tbl_contains(stop_dirs, current_path) do
        local found_marker = false

        for _, pattern in ipairs(patterns) do
            local marker_path = current_path .. "/" .. pattern
            local stat = vim.loop.fs_stat(marker_path)

            if stat then
                if pattern == ".git" and ignore_submodules and stat.type == "file" then
                    -- This is a submodule .git file, ignore it and continue searching upwards
                    -- Continue to next iteration without setting found_marker
                else
                    -- Found a valid root marker
                    root = current_path
                    found_marker = true
                    break
                end
            end
        end

        if found_marker then
            break
        end

        local parent = vim.fs.dirname(current_path)
        if parent == current_path then -- Reached filesystem root
            break
        end
        current_path = parent
    end

    -- Cache result (even if nil) to prevent future searches
    root_cache[cache_key] = root
    return root
end

function M.mason_install(pkgname, on_installed)
    local mason_registry = require("mason-registry")
    if not mason_registry.is_installed(pkgname) then
        local pkg = mason_registry.get_package(pkgname)
        pkg:install():once("closed", function()
            if mason_registry.is_installed(pkgname) then
                vim.schedule(function()
                    vim.notify(string.format("%s has been installed successfully!", pkgname), vim.log.levels.INFO)
                    if on_installed then
                        on_installed()
                    end
                end)
            else
                vim.schedule(function()
                    vim.notify(string.format("Failed to install %s.", pkgname), vim.log.levels.ERROR)
                end)
            end
        end)
    else
        if on_installed then
            on_installed()
        end
    end
end

function M.ts_install(parsername)
    local parsers = require("nvim-treesitter.parsers")
    if not parsers.has_parser(parsername) then
        vim.cmd("TSInstall " .. parsername)
    end
end

function M.current_repo_name()
    local current_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
    local project_root = M.find_project_root(current_dir, { ".git", "Cargo.toml", "rebar.config", "pyproject.toml" }, { ignore_submodules = true })
    return project_root and vim.fs.basename(project_root) or nil
end

function M.load_yaml(path)
    local yaml = require("lyaml")
    local file = io.open(path, "r")
    if not file then
        vim.notify("Failed to open YAML file: " .. path, vim.log.levels.ERROR)
        return nil
    end
    local content = file:read("*a")
    file:close()
    if content == "" then
        return nil
    end
    local success, result = pcall(yaml.load, content)
    if not success or not result then
        vim.notify("Failed to parse YAML file", vim.log.levels.ERROR)
        return nil
    end
    return result
end

function M.is_plugin_installed(name)
    local plugins = require("lazy").plugins() -- Get all configured plugins
    for _, plugin in ipairs(plugins) do
        if plugin.name == name then
            return plugin.enabled ~= false -- Check if enabled (defaults to true)
        end
    end
    return false
end

return M
