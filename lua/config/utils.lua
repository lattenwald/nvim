local M = {}

-- Cache for root finding to prevent redundant filesystem searches
local root_cache = {}

-- Default project root markers, shared with Snacks' picker root detection.
M.root_patterns = { ".git", "project-root" }

-- Stop at home and the filesystem root so a stray path can't walk the whole tree.
local stop_dirs = { vim.fn.expand("~"), "/" }

-- A .git file (not directory) points at the real gitdir, whose path says which kind it is
local GIT_KINDS = { worktrees = "worktree", modules = "submodule" }

function M.get_git_type(git_path)
    local stat = vim.uv.fs_stat(git_path)
    if not stat then
        return nil
    end

    if stat.type ~= "directory" then
        local file = io.open(git_path, "r")
        if file then
            local content = file:read("*l") or ""
            file:close()
            local kind = GIT_KINDS[content:match("gitdir:.*/%.git/(%w+)/")]
            if kind then
                return kind
            end
        end
    end

    return "repository"
end

-- Safe root finding with boundaries, caching, and submodule support
-- Not vim.fs.find: its predicate form lists every ancestor directory, where fs_stat is 2 syscalls per level
function M.find_project_root(start_path, patterns)
    patterns = patterns or M.root_patterns

    -- Ensure we start searching from a directory
    local start_stat = vim.uv.fs_stat(start_path)
    local start_dir = (start_stat and start_stat.type == "directory") and start_path or vim.fs.dirname(start_path)
    local current_path = vim.fs.normalize(start_dir)

    -- Keyed by directory, not by the file path callers pass in, which would miss once per file.
    local key_suffix = ":" .. table.concat(patterns, ",")
    local cached = root_cache[current_path .. key_suffix]
    if cached ~= nil then
        return cached or nil
    end

    local root = nil
    local walked = {}

    while current_path and not vim.tbl_contains(stop_dirs, current_path) do
        walked[#walked + 1] = current_path

        for _, pattern in ipairs(patterns) do
            local marker_path = current_path .. "/" .. pattern
            -- A submodule has its own .git file but belongs to the parent repository
            if vim.uv.fs_stat(marker_path) and not (pattern == ".git" and M.get_git_type(marker_path) == "submodule") then
                root = current_path
                break
            end
        end

        if root then
            break
        end

        local parent = vim.fs.dirname(current_path)
        if parent == current_path then -- Reached filesystem root
            break
        end
        current_path = parent
    end

    -- Every directory walked shares this root, so warm them all and never repeat the walk.
    -- false, not nil: a nil value stores no entry at all.
    for _, dir in ipairs(walked) do
        root_cache[dir .. key_suffix] = root or false
    end
    return root
end

function M.mason_install(pkgname, on_installed)
    local mason_registry = require("mason-registry")
    if mason_registry.is_installed(pkgname) then
        if on_installed then
            on_installed()
        end
        return
    end

    mason_registry.get_package(pkgname):install():once(
        "closed",
        vim.schedule_wrap(function()
            if not mason_registry.is_installed(pkgname) then
                vim.notify(string.format("Failed to install %s.", pkgname), vim.log.levels.ERROR)
                return
            end
            vim.notify(string.format("%s has been installed successfully!", pkgname), vim.log.levels.INFO)
            if on_installed then
                on_installed()
            end
        end)
    )
end

function M.lsp_setup(server_name, opts)
    if vim.fn.executable(server_name) ~= 1 then
        return false
    end

    if opts then
        vim.lsp.config(server_name, opts)
    end
    vim.lsp.enable(server_name)
    return true
end

-- silent: no warning for a missing file or missing lyaml; parse errors always notify.
function M.load_yaml(path, silent)
    local function warn(msg, level)
        if not silent then
            vim.notify(msg, level)
        end
    end

    local ok, yaml = pcall(require, "lyaml")
    if not ok then
        warn("lyaml not available - install via luarocks.nvim", vim.log.levels.WARN)
        return nil
    end
    local file = io.open(path, "r")
    if not file then
        warn("Failed to open YAML file: " .. path, vim.log.levels.ERROR)
        return nil
    end
    local content = file:read("*a")
    file:close()
    if content == "" then
        return nil
    end
    local success, result = pcall(yaml.load, content)
    if not success or not result then
        vim.notify("Failed to parse YAML file: " .. path, vim.log.levels.ERROR)
        return nil
    end
    return result
end

function M.has_gui()
    return vim.env.DISPLAY ~= nil or vim.env.WAYLAND_DISPLAY ~= nil or vim.g.neovide
end

return M
