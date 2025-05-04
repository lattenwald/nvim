local M = {}

function M.mason_install(pkgname)
    local mason_registry = require("mason-registry")
    if not mason_registry.is_installed(pkgname) then
        local pkg = mason_registry.get_package(pkgname)
        pkg:install():once("closed", function()
            if mason_registry.is_installed(pkgname) then
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

return M
