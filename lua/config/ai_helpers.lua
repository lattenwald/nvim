local M = {}

-- Selected helper, persisted across sessions.
local selection_file = vim.fn.stdpath("data") .. "/ai_helper_selection.txt"

local function save_selection(helper_name)
    pcall(vim.fn.writefile, { helper_name }, selection_file)
end

local function load_selection()
    local ok, lines = pcall(vim.fn.readfile, selection_file)
    local name = ok and lines[1]
    return name and vim.trim(name) or nil
end

-- Terminal configuration (can be overridden in setup)
M.terminal_config = {
    type = "float", -- "float" or "split"
    position = "right", -- for split: "right", "left", "top", "bottom"
    size = 0.5, -- for split: fraction of screen (0.0-1.0)
}

-- Helper configurations
M.helpers = {
    antigravity = {
        name = "Antigravity",
        cmd = "agy --add-dir .",
        icon = "󰊭",
    },
    droid = {
        name = "Droid",
        cmd = "droid",
        icon = "󰚩",
    },
    codex = {
        name = "Codex",
        cmd = "codex",
        icon = "󰧑",
    },
    cursor = {
        name = "Cursor",
        cmd = "cursor-agent",
        icon = "",
    },
    opencode = {
        name = "OpenCode",
        cmd = "opencode",
        icon = "󱚟",
        -- Dead port: otherwise opencode scans ~/.claude/ide/*.lock and joins claudecode.nvim's broadcasts
        env = { OPENCODE_EDITOR_SSE_PORT = "1" },
    },
}

M.current_helper = nil
M.terminal_instances = {}

local default_helper = nil

-- Machine-local map of helper -> env var -> pass entry, e.g.
--   opencode:
--     OPENROUTER_API_KEY: api/openrouter
local env_file = vim.fn.stdpath("data") .. "/ai_helper_env.yaml"
local env_cache = nil
local env_cache_mtime = nil
-- Resolved values, cached for the session so gpg-agent is hit once per entry.
local secrets = {}

-- Memoized; reloaded whenever ai_helper_env.yaml's mtime changes.
local function read_env_map()
    local stat = (vim.uv or vim.loop).fs_stat(env_file)
    local mtime = stat and stat.mtime
    if env_cache and env_cache_mtime and mtime and env_cache_mtime.sec == mtime.sec and env_cache_mtime.nsec == mtime.nsec then
        return env_cache
    end

    -- Silent: the file is optional. load_yaml requires lyaml lazily, keeping it off the startup path.
    local parsed = require("config.utils").load_yaml(env_file, true)

    env_cache = type(parsed) == "table" and parsed or {}
    env_cache_mtime = mtime
    return env_cache
end

-- false marks a failed lookup so a broken entry isn't retried on every spawn.
local function pass_show(entry)
    if secrets[entry] == nil then
        local ok, res = pcall(function()
            return vim.system({ "pass", "show", entry }, { text = true }):wait(15000)
        end)
        if ok and res.code == 0 then
            secrets[entry] = vim.split(res.stdout, "\n")[1]
        else
            secrets[entry] = false
            vim.notify("pass: could not read " .. entry, vim.log.levels.ERROR)
        end
    end
    return secrets[entry] or nil
end

local function helper_env(helper_name)
    local env = vim.deepcopy(M.helpers[helper_name].env or {})
    local mapping = read_env_map()[helper_name]
    if type(mapping) == "table" then
        for var, entry in pairs(mapping) do
            env[var] = pass_show(entry)
        end
    end
    return next(env) and env or nil
end

function M.get_current_config()
    if M.current_helper then
        return M.helpers[M.current_helper]
    end
    return nil
end

-- cmd may carry args (e.g. "agy --add-dir ."), so match only the binary token
local function helper_bin(helper)
    return helper.cmd:match("^%S+")
end

function M.is_available(helper_name)
    local helper = M.helpers[helper_name]
    return helper ~= nil and vim.fn.executable(helper_bin(helper)) == 1
end

function M.available_helpers()
    local names = vim.tbl_filter(M.is_available, vim.tbl_keys(M.helpers))
    table.sort(names)
    return names
end

function M.set_helper(helper_name, skip_notify)
    if not M.helpers[helper_name] then
        if not skip_notify then
            vim.notify("Unknown AI helper: " .. tostring(helper_name), vim.log.levels.ERROR)
        end
        return false
    end

    if not M.is_available(helper_name) then
        if not skip_notify then
            vim.notify("AI helper not installed: " .. M.helpers[helper_name].name, vim.log.levels.WARN)
        end
        return false
    end

    M.current_helper = helper_name
    save_selection(helper_name)

    if not skip_notify then
        vim.notify("AI Helper: " .. M.helpers[helper_name].name, vim.log.levels.INFO)
    end

    vim.schedule(function()
        local ok, lualine = pcall(require, "lualine")
        if ok then
            lualine.refresh()
        end
    end)

    return true
end

function M.switch_helper()
    local helper_names = M.available_helpers()

    if #helper_names == 0 then
        vim.notify("No AI helpers installed", vim.log.levels.WARN)
        return
    end

    vim.ui.select(helper_names, {
        prompt = "Select AI Helper:",
        format_item = function(item)
            local helper = M.helpers[item]
            local current = item == M.current_helper and " [current]" or ""
            return helper.icon .. " " .. helper.name .. current
        end,
    }, function(choice)
        if choice then
            M.set_helper(choice)
        end
    end)
end

-- Visual marks '< and '> are only set after leaving visual mode (:help '<).
-- When invoked via lazy.nvim's first-load stub the marks may still be [0,0,0,0],
-- so we read live positions while in visual mode and fall back to marks otherwise.
local function visual_lines()
    local mode = vim.fn.mode()
    local first, last
    if mode == "v" or mode == "V" or mode == "\22" then
        first, last = vim.fn.getpos("v")[2], vim.fn.getpos(".")[2]
    else
        first, last = vim.fn.getpos("'<")[2], vim.fn.getpos("'>")[2]
    end
    if first > last then
        first, last = last, first
    end
    return first, last
end

-- A hidden terminal keeps its buffer but has no window, so reuse on buf_valid.
local function get_or_create_terminal(cmd)
    local helper_name = M.current_helper
    local term = M.terminal_instances[helper_name]

    if term and term:buf_valid() then
        return term, false
    end

    local term_opts = { cwd = vim.fn.getcwd(), env = helper_env(helper_name) }

    if M.terminal_config.type == "split" then
        local pos = M.terminal_config.position
        local size = M.terminal_config.size
        term_opts.win = {
            position = pos,
            width = (pos == "left" or pos == "right") and size or nil,
            height = (pos == "top" or pos == "bottom") and size or nil,
        }
    end

    term = Snacks.terminal(cmd, term_opts)
    M.terminal_instances[helper_name] = term
    term.ai_helper = helper_name
    -- Spawn cwd, kept for relative sends: nvim's cwd drifts via autochdir while the agent stays here
    term.ai_cwd = term_opts.cwd

    return term, true
end

-- The buffer path must be read before the terminal takes focus.
local function terminal_and_file()
    local helper = M.get_current_config()
    if not helper then
        vim.notify("No AI helper selected. Use :AIHelperSwitch", vim.log.levels.WARN)
        return nil
    end

    local abs = vim.fn.expand("%:p")
    local term = get_or_create_terminal(helper.cmd)
    if not term then
        return nil
    end

    return term, vim.fs.relpath(term.ai_cwd or vim.fn.getcwd(), abs) or abs
end

local function send_to_terminal(term, write)
    term:show()
    write(vim.b[term.buf].terminal_job_id)
    term:focus()
    vim.cmd("startinsert")
end

function M.toggle_terminal()
    local helper = M.get_current_config()
    if not helper then
        vim.notify("No AI helper selected. Use :AIHelperSwitch", vim.log.levels.WARN)
        return
    end

    local term, created = get_or_create_terminal(helper.cmd)
    -- Newly created terminals are already shown by Snacks.terminal()
    if term and not created then
        term:toggle()
    end
end

-- Claude Code format: @file#L1 or @file#L1-5
function M.send_selection()
    local start_line, end_line = visual_lines()
    local term, file = terminal_and_file()
    if not term then
        return
    end

    local location = "@" .. file .. "#L" .. start_line
    if start_line ~= end_line then
        location = location .. "-" .. end_line
    end

    send_to_terminal(term, function(chan)
        vim.api.nvim_chan_send(chan, location .. " ")
    end)
end

function M.send_buffer()
    local term, file = terminal_and_file()
    if not term then
        return
    end

    send_to_terminal(term, function(chan)
        vim.api.nvim_chan_send(chan, "@" .. file .. " ")
    end)
end

function M.get_helper_from_buffer(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    for helper_name, term in pairs(M.terminal_instances) do
        if term and term:buf_valid() and term.buf == bufnr then
            return helper_name
        end
    end

    return nil
end

local function buf_visible(bufnr)
    return bufnr ~= nil and #vim.fn.win_findbuf(bufnr) > 0
end

local function is_ai_helper_visible()
    for _, term in pairs(M.terminal_instances) do
        if term and term:buf_valid() and buf_visible(term.buf) then
            return true
        end
    end
    return false
end

local function cc_bufnr()
    local ok, cc = pcall(require, "claudecode.terminal")
    return ok and cc.get_active_terminal_bufnr() or nil
end

local function is_claudecode_visible()
    return buf_visible(cc_bufnr())
end

-- Which agent owns a buffer: helper name, "claude", or nil.
function M.agent_for_buf(bufnr)
    return M.get_helper_from_buffer(bufnr) or (cc_bufnr() == bufnr and "claude" or nil)
end

local ai_cmd_set = nil

-- Binary names that mark an AI terminal we don't own: claude plus every helper command.
function M.ai_commands()
    if not ai_cmd_set then
        ai_cmd_set = { claude = true }
        for _, helper in pairs(M.helpers) do
            ai_cmd_set[vim.fs.basename(helper_bin(helper))] = true
        end
    end
    return ai_cmd_set
end

-- Delete the TermClose handler before closing, else closing kills the job and its exit -1 is logged as a crash.
-- Delete by id: the handler is in a snacks augroup, and a buffer-scoped nvim_clear_autocmds skips grouped autocmds.
function M.kill_claude_terminal()
    local ok, cc = pcall(require, "claudecode.terminal")
    local bufnr = ok and cc.get_active_terminal_bufnr()
    if not bufnr then
        return false
    end
    for _, au in ipairs(vim.api.nvim_get_autocmds({ event = "TermClose", buffer = bufnr })) do
        pcall(vim.api.nvim_del_autocmd, au.id)
    end
    cc.close()
    return true
end

-- Claude subscription (work/personal) switcher.
local sub = {
    current = nil,
    config_dir = vim.fn.expand("~/.claude-personal"),
}

function M.claude_has_personal_config()
    return vim.fn.isdirectory(sub.config_dir) == 1
end

local function apply_sub(choice)
    if choice == "personal" and not M.claude_has_personal_config() then
        vim.notify("Claude: config dir not found: " .. sub.config_dir, vim.log.levels.ERROR)
        return false
    end
    sub.current = choice
    return true
end

-- Set the override only around the spawn, clearing even on error, so it never persists on the global env for children to inherit.
local function run_claude(cmd)
    if sub.current == "personal" then
        vim.fn.system({ "bash", vim.fn.expand("~/.claude/scripts/sync-personal-links.sh") })
        vim.env.CLAUDE_CONFIG_DIR = sub.config_dir
    end
    local ok, err = pcall(vim.cmd, cmd)
    vim.env.CLAUDE_CONFIG_DIR = nil
    if not ok then
        error(err)
    end
end

function M.claude_select_account(callback)
    vim.ui.select({ "work", "personal" }, {
        prompt = "Claude subscription:",
        format_item = function(item)
            return (item == sub.current and "● " or "○ ") .. item
        end,
    }, function(choice)
        if not choice then
            return
        end
        local prev = sub.current
        if not apply_sub(choice) then
            return
        end
        if prev and prev ~= choice then
            local had_terminal = M.kill_claude_terminal()
            vim.notify("Claude: " .. choice .. " (terminal restarted)", vim.log.levels.INFO)
            if callback then
                callback()
            elseif had_terminal then
                run_claude("ClaudeCode")
            end
        else
            vim.notify("Claude: " .. choice, vim.log.levels.INFO)
            if callback then
                callback()
            end
        end
    end)
end

function M.claude_toggle(cmd)
    cmd = cmd or "ClaudeCode"
    if sub.current or not M.claude_has_personal_config() then
        run_claude(cmd)
    else
        M.claude_select_account(function()
            run_claude(cmd)
        end)
    end
end

local function route_send(claude_action, helper_action)
    local claude = is_claudecode_visible()
    local helper = is_ai_helper_visible()
    if claude and helper then
        local options = {
            { label = "Claude Code", action = claude_action },
            { label = "AI Helper", action = helper_action },
        }
        vim.ui.select(options, {
            prompt = "Send to:",
            format_item = function(item)
                return item.label
            end,
        }, function(choice)
            if choice then
                choice.action()
            end
        end)
    elseif helper then
        helper_action()
    else
        claude_action()
    end
end

function M.smart_send_selection()
    route_send(function()
        -- Explicit range, not '<,'>: marks aren't set on the first lazy call, but visual_lines() reads live positions.
        vim.cmd(string.format("%d,%dClaudeCodeSend", visual_lines()))
    end, M.send_selection)
end

function M.smart_send_buffer()
    route_send(function()
        vim.cmd("ClaudeCodeAdd %")
    end, M.send_buffer)
end

function M.lualine_component()
    if M.current_helper then
        local helper = M.helpers[M.current_helper]
        return helper.icon .. " " .. helper.name
    end
    return "󰚩 No AI"
end

function M.setup(opts)
    opts = opts or {}

    if opts.default_helper then
        default_helper = opts.default_helper
    end

    if opts.terminal then
        M.terminal_config = vim.tbl_deep_extend("force", M.terminal_config, opts.terminal)
    end

    if opts.helpers then
        M.helpers = vim.tbl_deep_extend("force", M.helpers, opts.helpers)
        ai_cmd_set = nil
    end

    local stored = load_selection()
    -- set_helper rejects (returns false for) uninstalled helpers, so fall back
    -- to the default when the stored helper is missing or no longer present.
    if not (stored and M.set_helper(stored, true)) and M.helpers[default_helper] then
        M.set_helper(default_helper, true)
    end
    vim.api.nvim_create_user_command("AIHelperSwitch", function(cmd_opts)
        if cmd_opts.args ~= "" then
            M.set_helper(cmd_opts.args)
        else
            M.switch_helper()
        end
    end, {
        nargs = "?",
        complete = function()
            return M.available_helpers()
        end,
        desc = "Switch AI helper",
    })

    vim.api.nvim_create_user_command("AIHelperToggle", M.toggle_terminal, { desc = "Toggle AI helper terminal" })

    vim.api.nvim_create_user_command("AIHelperSend", M.send_selection, { desc = "Send selection to AI helper", range = true })

    vim.api.nvim_create_user_command("AIHelperSendBuffer", M.send_buffer, { desc = "Send current buffer to AI helper" })
end

return M
