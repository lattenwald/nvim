local M = {}

-- Storage backends for persisting selected helper
M.storage = {
    memory = {
        data = nil,
        save = function(helper_name)
            M.storage.memory.data = helper_name
        end,
        load = function()
            return M.storage.memory.data
        end,
    },
    file = {
        path = vim.fn.stdpath("data") .. "/ai_helper_selection.txt",
        save = function(helper_name)
            local file = io.open(M.storage.file.path, "w")
            if file then
                file:write(helper_name)
                file:close()
            end
        end,
        load = function()
            local file = io.open(M.storage.file.path, "r")
            if file then
                local content = file:read("*all")
                file:close()
                return content:match("^%s*(.-)%s*$")
            end
            return nil
        end,
    },
}

M.current_storage = "memory" -- can be changed to "file" for persistence

-- Terminal configuration (can be overridden in setup)
M.terminal_config = {
    type = "float", -- "float" or "split"
    position = "right", -- for split: "right", "left", "top", "bottom"
    size = 0.5, -- for split: fraction of screen (0.0-1.0)
}

-- Helper configurations
M.helpers = {
    droid = {
        name = "Droid",
        cmd = "droid",
        icon = "󰚩",
        send_format = "file_line",
    },
    codex = {
        name = "Codex",
        cmd = "codex",
        icon = "󰧑",
        send_format = "file_line",
    },
    cursor = {
        name = "Cursor",
        cmd = "cursor-agent",
        icon = "",
        send_format = "text",
    },
    gemini = {
        name = "Gemini",
        cmd = "gemini",
        icon = "",
        send_format = "file_line",
    },
}

M.current_helper = nil
M.default_helper = "gemini"
M.terminal_instances = {}

function M.get_current()
    return M.current_helper
end

function M.get_current_config()
    if M.current_helper then
        return M.helpers[M.current_helper]
    end
    return nil
end

function M.set_helper(helper_name, skip_notify)
    if not M.helpers[helper_name] then
        vim.notify("Unknown AI helper: " .. helper_name, vim.log.levels.ERROR)
        return false
    end

    M.current_helper = helper_name

    if M.storage[M.current_storage] then
        M.storage[M.current_storage].save(helper_name)
    end

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
    local helper_names = vim.tbl_keys(M.helpers)
    table.sort(helper_names)

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
local function visual_bounds()
    local mode = vim.fn.mode()
    local s_pos, e_pos
    if mode == "v" or mode == "V" or mode == "\22" then
        s_pos = vim.fn.getpos("v")
        e_pos = vim.fn.getpos(".")
    else
        s_pos = vim.fn.getpos("'<")
        e_pos = vim.fn.getpos("'>")
    end
    if s_pos[2] > e_pos[2] or (s_pos[2] == e_pos[2] and s_pos[3] > e_pos[3]) then
        s_pos, e_pos = e_pos, s_pos
    end
    if mode == "V" then
        s_pos[3] = 1
        e_pos[3] = vim.v.maxcol
    end
    return s_pos, e_pos
end

function M.get_selection()
    local start_pos, end_pos = visual_bounds()
    local lines = vim.fn.getline(start_pos[2], end_pos[2])

    if #lines == 0 then
        return nil, start_pos, end_pos
    end

    if #lines == 1 then
        lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
    else
        lines[1] = string.sub(lines[1], start_pos[3])
        lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
    end

    return table.concat(lines, "\n"), start_pos, end_pos
end

-- Snacks terminal exposes buf as a number on some versions and as a table on others
local function term_bufnr(term)
    return type(term.buf) == "number" and term.buf or term.buf.buf
end

local function get_or_create_terminal(cmd)
    local helper_name = M.current_helper
    local term = M.terminal_instances[helper_name]

    if term and term:valid() then
        return term, false
    end

    local term_opts = { cwd = vim.fn.getcwd() }

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

    return term, true
end

local function helper_filename(helper)
    return helper.absolute_path and vim.fn.expand("%:p") or vim.fn.expand("%:.")
end

local function send_to_terminal(cmd, write)
    local term = get_or_create_terminal(cmd)
    if not term then
        return
    end
    term:show()
    write(vim.api.nvim_buf_get_var(term_bufnr(term), "terminal_job_id"))
    if term.win and vim.api.nvim_win_is_valid(term.win) then
        vim.api.nvim_set_current_win(term.win)
        vim.cmd("startinsert")
    end
end

function M.toggle_terminal()
    local helper = M.get_current_config()
    if not helper then
        vim.notify("No AI helper selected. Use :AIHelperSwitch", vim.log.levels.WARN)
        return
    end

    local term, created = get_or_create_terminal(helper.cmd)
    -- Newly created terminals are already shown by Snacks.terminal()
    if not term or created then
        return
    end
    local win_visible = term.win and vim.api.nvim_win_is_valid(term.win)
    if win_visible then
        term:hide()
    else
        term:show()
    end
end

function M.send_selection()
    local helper = M.get_current_config()
    if not helper then
        vim.notify("No AI helper selected. Use :AIHelperSwitch", vim.log.levels.WARN)
        return
    end

    local file = helper_filename(helper)

    if helper.send_format == "file_line" then
        -- Claude Code format: @file#L1 or @file#L1-5
        local start_pos, end_pos = visual_bounds()
        local start_line = start_pos[2]
        local end_line = end_pos[2]

        local location = "@" .. file .. "#L" .. start_line
        if start_line ~= end_line then
            location = location .. "-" .. end_line
        end

        send_to_terminal(helper.cmd, function(chan)
            vim.api.nvim_chan_send(chan, location .. " ")
        end)
    else
        local selection, start_pos, end_pos = M.get_selection()
        if not selection then
            vim.notify("No selection found", vim.log.levels.WARN)
            return
        end

        local header = "--- " .. file .. ":" .. start_pos[2] .. "-" .. end_pos[2] .. "\n"

        send_to_terminal(helper.cmd, function(chan)
            vim.api.nvim_chan_send(chan, header)
            for line in selection:gmatch("[^\n]+") do
                vim.api.nvim_chan_send(chan, line .. "\n")
            end
            vim.api.nvim_chan_send(chan, "---\n")
        end)
    end
end

function M.send_buffer()
    local helper = M.get_current_config()
    if not helper then
        vim.notify("No AI helper selected. Use :AIHelperSwitch", vim.log.levels.WARN)
        return
    end

    local file = helper_filename(helper)

    send_to_terminal(helper.cmd, function(chan)
        vim.api.nvim_chan_send(chan, "@" .. file .. " ")
    end)
end

function M.get_helper_from_buffer(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    for helper_name, term in pairs(M.terminal_instances) do
        if term and term:valid() and term_bufnr(term) == bufnr then
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
        if term and term:valid() and buf_visible(term_bufnr(term)) then
            return true
        end
    end
    return false
end

local function is_claudecode_visible()
    local ok, cc_term = pcall(require, "claudecode.terminal")
    if not ok then
        return false
    end
    return buf_visible(cc_term.get_active_terminal_bufnr())
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
        vim.cmd("'<,'>ClaudeCodeSend")
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
        M.default_helper = opts.default_helper
    end

    if opts.storage then
        M.current_storage = opts.storage
    end

    if opts.terminal then
        M.terminal_config = vim.tbl_deep_extend("force", M.terminal_config, opts.terminal)
    end

    if opts.helpers then
        M.helpers = vim.tbl_deep_extend("force", M.helpers, opts.helpers)
    end

    local stored = M.storage[M.current_storage].load()
    if stored and M.helpers[stored] then
        M.set_helper(stored, true)
    else
        M.set_helper(M.default_helper, true)
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
            return vim.tbl_keys(M.helpers)
        end,
        desc = "Switch AI helper",
    })

    vim.api.nvim_create_user_command("AIHelperToggle", function()
        M.toggle_terminal()
    end, { desc = "Toggle AI helper terminal" })

    vim.api.nvim_create_user_command("AIHelperSend", function()
        M.send_selection()
    end, { desc = "Send selection to AI helper", range = true })

    vim.api.nvim_create_user_command("AIHelperSendBuffer", function()
        M.send_buffer()
    end, { desc = "Send current buffer to AI helper" })
end

return M
