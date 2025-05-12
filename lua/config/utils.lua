local M = {}

function M.mason_install(pkgname)
    local mason_registry = require("mason-registry")
    if not mason_registry.is_installed(pkgname) then
        local pkg = mason_registry.get_package(pkgname)
        pkg:install():once("closed", function()
            if not mason_registry.is_installed(pkgname) then
                vim.notify(string.format("%s has been installed successfully!", pkgname), vim.log.levels.INFO)
            else
                vim.notify(string.format("Failed to install %s.", pkgname), vim.log.levels.ERROR)
            end
        end)
    end
end

function M.ts_install(parsername)
    local parsers = require("nvim-treesitter.parsers")
    if not parsers.has_parser(parsername) then
        vim.cmd("TSInstall " .. parsername)
    end
end

function M.current_repo_name()
    local dir = vim.fs.find(".git", {
        upward = true,
        stop = vim.loop.os_homedir(),
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    })[1]
    if not dir then
        dir = vim.fs.find({ "Cargo.toml", "rebar.config", "pyproject.toml" }, {
            upward = true,
            stop = vim.loop.os_homedir(),
            path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
        })[1]
    end
    local repo_dir = vim.fs.dirname(dir)
    return vim.fs.basename(repo_dir)
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
