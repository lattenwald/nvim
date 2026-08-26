-- Builds the window title "<project> :: <rest>".
--
-- <project>: registered project (projects.yaml) containing getcwd() — basename when
-- unique, else "parent/base" or "topchunk/../base" to disambiguate.
-- <rest>: file path relative to the project root, or a terminal label AI(<cmd>) /
-- term(<cmd>).
-- Outside any registered project: titlestring "" (Neovim's default title).
local M = {}

local function path_chunks(path)
    local chunks = {}
    for chunk in path:gmatch("[^/]+") do
        chunks[#chunks + 1] = chunk
    end
    return chunks
end

-- True if a and b share their last k chunks.
local function suffix_equal(a, b, k)
    local na, nb = #a, #b
    if na < k or nb < k then
        return false
    end
    for i = 0, k - 1 do
        if a[na - i] ~= b[nb - i] then
            return false
        end
    end
    return true
end

-- Shortest unique chunk-suffix of proj_chunks: base / parent/base / topchunk/../base.
local function disambiguate(proj_chunks, others)
    local n = #proj_chunks
    for k = 1, n do
        local collides = false
        for _, other in ipairs(others) do
            if suffix_equal(proj_chunks, other, k) then
                collides = true
                break
            end
        end
        if not collides then
            local base = proj_chunks[n]
            if k == 1 then
                return base
            elseif k == 2 then
                return proj_chunks[n - 1] .. "/" .. base
            else
                return proj_chunks[n - (k - 1)] .. "/../" .. base
            end
        end
    end
    -- No unique suffix (duplicate entry): use basename.
    return proj_chunks[n]
end

-- Valid while cwd holds: get_projects returns the same table until projects.yaml changes.
local cached = {}

-- Registered project containing cwd (nearest ancestor), or nil.
local function compute_prefix(cwd)
    cwd = vim.fs.normalize(cwd)
    local projects = require("config.project").get_projects()
    if cached.cwd == cwd and cached.projects == projects then
        return cached.prefix
    end

    local match_path
    for _, project in ipairs(projects) do
        local path = project.path
        if cwd == path or cwd:sub(1, #path + 1) == path .. "/" then
            if not match_path or #path > #match_path then
                match_path = path
            end
        end
    end

    local prefix
    if match_path then
        local others = {}
        for _, project in ipairs(projects) do
            if project.path ~= match_path then
                others[#others + 1] = path_chunks(project.path)
            end
        end
        prefix = { display = disambiguate(path_chunks(match_path), others), path = match_path }
    end

    cached = { cwd = cwd, projects = projects, prefix = prefix }
    return prefix
end

-- Command basename from the "term://…:<cmd>" buffer name.
local function term_command(bufnr)
    local name = vim.api.nvim_buf_get_name(bufnr)
    local cmd = name:match("//%d+:(.*)$")
    if not cmd or cmd == "" then
        cmd = vim.b[bufnr].term_title
    end
    if not cmd or cmd == "" then
        return nil
    end
    local first = cmd:match("^%S+") or cmd
    local base = vim.fs.basename(first)
    return base ~= "" and base or first
end

-- AI(<cmd>) / term(<cmd>) for a terminal buffer, or nil for non-terminals.
local function terminal_label(bufnr)
    if vim.bo[bufnr].buftype ~= "terminal" then
        return nil
    end

    local cmd = term_command(bufnr)
    local ok, ai = pcall(require, "config.ai_helpers")
    local owner = ok and ai.agent_for_buf(bufnr) or nil

    if owner == "claude" and (not cmd or cmd == "") then
        cmd = "claude"
    end

    local is_ai = owner ~= nil or (ok and cmd ~= nil and ai.ai_commands()[cmd] == true)

    cmd = cmd or "term"
    return (is_ai and "AI(" or "term(") .. cmd .. ")"
end

-- File path relative to the project root, with a modified flag.
local function file_rest(bufnr, proj_path)
    local file = vim.api.nvim_buf_get_name(bufnr)
    if file == "" then
        return "[No Name]"
    end

    local norm = vim.fs.normalize(file)
    local rest
    if proj_path and norm:sub(1, #proj_path + 1) == proj_path .. "/" then
        rest = norm:sub(#proj_path + 2)
    else
        rest = vim.fn.fnamemodify(file, ":~")
    end

    if vim.bo[bufnr].modified then
        rest = rest .. " [+]"
    end
    return rest
end

-- Double "%" — the titlestring escape character.
local function escape(str)
    return (str:gsub("%%", "%%%%"))
end

local function update_title()
    local prefix = compute_prefix(vim.fn.getcwd())
    if not prefix then
        vim.o.titlestring = ""
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local rest = terminal_label(bufnr) or file_rest(bufnr, prefix.path)
    vim.o.titlestring = escape(prefix.display .. " :: " .. rest)
end

function M.setup()
    vim.o.title = true
    vim.o.titleold = ""
    local group = vim.api.nvim_create_augroup("WindowTitle", { clear = true })
    vim.api.nvim_create_autocmd({ "DirChanged", "BufEnter", "BufWinEnter", "TermOpen", "BufModifiedSet" }, {
        group = group,
        callback = update_title,
    })
    -- Deferred: the first run pulls in lyaml and parses projects.yaml, and no title is visible yet.
    vim.schedule(update_title)
end

return M
