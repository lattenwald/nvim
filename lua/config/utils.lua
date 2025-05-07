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

return M
