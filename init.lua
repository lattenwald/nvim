function current_repo_name()
    local dir = vim.fs.find(".git", {
        upward = true,
        stop = vim.loop.os_homedir(),
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    })[1]
    if not dir then
        dir = vim.fs.find("Cargo.toml", {
            upward = true,
            stop = vim.loop.os_homedir(),
            path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
        })[1]
    end
    local repo_dir = vim.fs.dirname(dir)
    return vim.fs.basename(repo_dir)
end

function project_dir()
    local dir = vim.fs.find(".git", {
        upward = true,
        stop = vim.loop.os_homedir(),
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    })[1]
    if not dir then
        dir = vim.fs.find("Cargo.toml", {
            upward = true,
            stop = vim.loop.os_homedir(),
            path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
        })[1]
    end
    return vim.fs.dirname(dir)
end

require("config.opts")
require("config.keys")
require("config.lazy")

vim.cmd("colorscheme tokyonight-night")
