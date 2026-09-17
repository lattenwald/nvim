local M = {}

local prefs_file = vim.fn.stdpath("data") .. "/ai_helpers.json"
local prefs = nil

local function get_prefs()
    if not prefs then
        local ok, data = pcall(function()
            return vim.json.decode(table.concat(vim.fn.readfile(prefs_file), "\n"))
        end)
        data = ok and type(data) == "table" and data or {}
        prefs = {
            order = type(data.order) == "table" and data.order or {},
            disabled = type(data.disabled) == "table" and data.disabled or {},
            last = type(data.last) == "string" and data.last or nil,
        }
    end
    return prefs
end

local function save_prefs()
    pcall(vim.fn.writefile, { vim.json.encode(prefs) }, prefs_file)
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

M.terminal_instances = {}

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

-- cmd may carry args (e.g. "agy --add-dir ."), so match only the binary token
local function helper_bin(helper)
    return helper.cmd:match("^%S+")
end

function M.is_available(helper_name)
    local helper = M.helpers[helper_name]
    return helper ~= nil and vim.fn.executable(helper_bin(helper)) == 1
end

function M.is_enabled(helper_name)
    return not get_prefs().disabled[helper_name]
end

function M.ordered_helpers()
    local seen, names = {}, {}
    for _, name in ipairs(get_prefs().order) do
        if M.helpers[name] and not seen[name] then
            seen[name] = true
            names[#names + 1] = name
        end
    end
    local rest = vim.tbl_filter(function(name)
        return not seen[name]
    end, vim.tbl_keys(M.helpers))
    table.sort(rest)
    return vim.list_extend(names, rest)
end

function M.enabled_helpers()
    return vim.tbl_filter(function(name)
        return M.is_enabled(name) and M.is_available(name)
    end, M.ordered_helpers())
end

local function is_running(helper_name)
    local term = M.terminal_instances[helper_name]
    return term ~= nil and term:buf_valid()
end

local function remember_last(helper_name)
    local p = get_prefs()
    if p.last ~= helper_name then
        p.last = helper_name
        save_prefs()
    end
end

local function pick_helper(on_choice)
    local names = M.enabled_helpers()
    if #names == 0 then
        vim.notify("No AI helpers enabled. Use :AIHelperManage", vim.log.levels.WARN)
        return
    end
    if #names == 1 then
        return on_choice(names[1])
    end

    local last = get_prefs().last
    vim.ui.select(names, {
        prompt = "AI Helper",
        format_item = function(name)
            local helper = M.helpers[name]
            return helper.icon .. " " .. helper.name .. (is_running(name) and " [running]" or "")
        end,
        snacks = {
            on_show = function(picker)
                for i, name in ipairs(names) do
                    if name == last then
                        picker.list:set_target(i) -- snacks holds the target until row i exists
                        break
                    end
                end
            end,
        },
    }, function(name)
        if name then
            remember_last(name)
            on_choice(name)
        end
    end)
end

function M.manage_helpers()
    local p = get_prefs()

    local function move(picker, delta)
        local item = picker:current()
        local names = M.ordered_helpers()
        local to = item and item.idx + delta
        if not to or to < 1 or to > #names then
            return
        end
        names[item.idx], names[to] = names[to], names[item.idx]
        p.order = names
        save_prefs()
        picker.list:set_target(picker.list.cursor + delta, nil, { force = true })
        picker:refresh()
    end

    local keys = {
        ["<Tab>"] = { "toggle_helper", mode = { "n", "i" } },
        ["<a-j>"] = { "move_down", mode = { "n", "i" } },
        ["<a-k>"] = { "move_up", mode = { "n", "i" } },
    }

    Snacks.picker.pick({
        title = "AI Helpers  <Tab> toggle  <A-j/k> move  <CR> open",
        layout = { preset = "select" },
        finder = function()
            local items = {}
            for i, name in ipairs(M.ordered_helpers()) do
                items[#items + 1] = { idx = i, name = name, text = M.helpers[name].name, installed = M.is_available(name) }
            end
            return items
        end,
        format = function(item)
            local helper = M.helpers[item.name]
            local enabled = M.is_enabled(item.name)
            local ret = {
                { enabled and "● " or "○ ", enabled and "DiagnosticOk" or "Comment" },
                { helper.icon .. " " .. helper.name, item.installed and "Normal" or "Comment" },
            }
            if not item.installed then
                ret[#ret + 1] = { "  not installed", "Comment" }
            elseif is_running(item.name) then
                ret[#ret + 1] = { "  running", "DiagnosticInfo" }
            end
            return ret
        end,
        actions = {
            toggle_helper = function(picker, item)
                if item then
                    p.disabled[item.name] = M.is_enabled(item.name) or nil
                    save_prefs()
                    picker:refresh()
                end
            end,
            move_up = function(picker)
                move(picker, -1)
            end,
            move_down = function(picker)
                move(picker, 1)
            end,
            confirm = function(picker, item)
                picker:close()
                if item then
                    remember_last(item.name)
                    vim.schedule(function()
                        M.toggle_terminal(item.name)
                    end)
                end
            end,
        },
        win = { input = { keys = keys }, list = { keys = keys } },
    })
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
local function get_or_create_terminal(helper_name)
    if is_running(helper_name) then
        return M.terminal_instances[helper_name], false
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

    local term = Snacks.terminal(M.helpers[helper_name].cmd, term_opts)
    M.terminal_instances[helper_name] = term
    term.ai_helper = helper_name
    -- Spawn cwd, kept for relative sends: nvim's cwd drifts via autochdir while the agent stays here
    term.ai_cwd = term_opts.cwd

    return term, true
end

local function buf_visible(bufnr)
    return bufnr ~= nil and #vim.fn.win_findbuf(bufnr) > 0
end

local function visible_helpers()
    return vim.tbl_filter(function(name)
        return is_running(name) and buf_visible(M.terminal_instances[name].buf)
    end, M.ordered_helpers())
end

-- claudecode.nvim patches its terminal's :hide(), so Claude Code hides like a helper.
local function hide_agent_terminals(include_claude)
    local hidden = 0
    for _, term in ipairs(Snacks.terminal.list()) do
        local agent = term:valid() and M.agent_for_buf(term.buf)
        if agent and (include_claude or agent ~= "claude") then
            term:hide()
            hidden = hidden + 1
        end
    end
    return hidden
end

-- The buffer path must be read before the picker or terminal takes focus.
local function send_to_terminal(text)
    local abs = vim.fn.expand("%:p")
    local function send(helper_name)
        local term = get_or_create_terminal(helper_name)
        local file = vim.fs.relpath(term.ai_cwd or vim.fn.getcwd(), abs) or abs
        term:show()
        vim.api.nvim_chan_send(vim.b[term.buf].terminal_job_id, text(file))
        term:focus()
        vim.cmd("startinsert")
    end

    local visible = visible_helpers()
    if #visible > 0 then
        send(visible[1])
    else
        pick_helper(send)
    end
end

function M.toggle_terminal(helper_name)
    if not helper_name then
        if hide_agent_terminals(false) == 0 then
            pick_helper(M.toggle_terminal)
        end
        return
    end

    if not M.is_available(helper_name) then
        vim.notify("AI helper not installed: " .. tostring(helper_name), vim.log.levels.WARN)
        return
    end

    local term, created = get_or_create_terminal(helper_name)
    -- Newly created terminals are already shown by Snacks.terminal()
    if not created then
        term:toggle()
    end
end

-- Claude Code format: @file#L1 or @file#L1-5
function M.send_selection()
    local start_line, end_line = visual_lines()
    local range = start_line == end_line and start_line or (start_line .. "-" .. end_line)
    send_to_terminal(function(file)
        return "@" .. file .. "#L" .. range .. " "
    end)
end

function M.send_buffer()
    send_to_terminal(function(file)
        return "@" .. file .. " "
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

-- Not require(): lazy.nvim's require hook would load claudecode.nvim and start its server.
local function cc_bufnr()
    local cc = package.loaded["claudecode.terminal"]
    return cc and cc.get_active_terminal_bufnr() or nil
end

local function is_claudecode_visible()
    return buf_visible(cc_bufnr())
end

function M.hide_all()
    hide_agent_terminals(true)
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
    local helper = #visible_helpers() > 0
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

function M.setup(opts)
    opts = opts or {}

    if opts.terminal then
        M.terminal_config = vim.tbl_deep_extend("force", M.terminal_config, opts.terminal)
    end

    if opts.helpers then
        M.helpers = vim.tbl_deep_extend("force", M.helpers, opts.helpers)
        ai_cmd_set = nil
    end

    vim.api.nvim_create_user_command("AIHelperManage", M.manage_helpers, { desc = "Enable, disable and reorder AI helpers" })

    vim.api.nvim_create_user_command("AIHelperToggle", function(cmd_opts)
        M.toggle_terminal(cmd_opts.args ~= "" and cmd_opts.args or nil)
    end, {
        nargs = "?",
        complete = M.enabled_helpers,
        desc = "Toggle AI helper terminal",
    })

    vim.api.nvim_create_user_command("AIHelperSend", M.send_selection, { desc = "Send selection to AI helper", range = true })

    vim.api.nvim_create_user_command("AIHelperSendBuffer", M.send_buffer, { desc = "Send current buffer to AI helper" })
end

return M
