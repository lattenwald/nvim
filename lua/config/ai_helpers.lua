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
    gemini = {
        name = "Gemini",
        cmd = "gemini",
        icon = "",
        send_format = "file_line",
    },
    cursor = {
        name = "Cursor",
        cmd = "cursor-agent",
        icon = "",
        send_format = "text",
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
function M.get_selection()
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local lines = vim.fn.getline(start_pos[2], end_pos[2])

    if #lines == 0 then
        return nil
    end

    if #lines == 1 then
        lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
    else
        lines[1] = string.sub(lines[1], start_pos[3])
        lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
    end

    return table.concat(lines, "\n")
end
local function get_or_create_terminal(cmd)
    local ok, snacks = pcall(require, "snacks")
    if not ok then
        vim.notify("Snacks.nvim not available", vim.log.levels.ERROR)
        return nil
    end

    local helper_name = M.current_helper
    local term = M.terminal_instances[helper_name]

    if term and term:valid() then
        return term
    end

    local term_opts = { cwd = vim.fn.getcwd() }

    if M.terminal_config.type == "split" then
        term_opts.win = {
            position = M.terminal_config.position,
            width = M.terminal_config.position == "left" or M.terminal_config.position == "right" and M.terminal_config.size or nil,
            height = M.terminal_config.position == "top" or M.terminal_config.position == "bottom" and M.terminal_config.size or nil,
        }
    end

    term = Snacks.terminal(cmd, term_opts)
    M.terminal_instances[helper_name] = term
    term.ai_helper = helper_name

    return term
end
function M.toggle_terminal()
    local helper = M.get_current_config()
    if not helper then
        vim.notify("No AI helper selected. Use :AIHelperSwitch", vim.log.levels.WARN)
        return
    end

    get_or_create_terminal(helper.cmd)
end
function M.send_selection()
    local helper = M.get_current_config()
    if not helper then
        vim.notify("No AI helper selected. Use :AIHelperSwitch", vim.log.levels.WARN)
        return
    end

    if helper.send_format == "file_line" then
        -- Claude Code format: @file#L1 or @file#L1-5
        local file = vim.fn.expand("%:p")
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        local start_line = start_pos[2]
        local end_line = end_pos[2]

        local location = "@" .. file .. "#L" .. start_line
        if start_line ~= end_line then
            location = location .. "-" .. end_line
        end

        local term = get_or_create_terminal(helper.cmd)
        if term then
            term:show()
            -- Snacks terminal object may have buf as number or table
            local buf = type(term.buf) == "number" and term.buf or term.buf.buf
            local chan = vim.api.nvim_buf_get_var(buf, "terminal_job_id")
            vim.api.nvim_chan_send(chan, location .. " ")
        end
    else
        local selection = M.get_selection()
        if not selection then
            vim.notify("No selection found", vim.log.levels.WARN)
            return
        end

        local term = get_or_create_terminal(helper.cmd)
        if term then
            term:show()
            local buf = type(term.buf) == "number" and term.buf or term.buf.buf
            local chan = vim.api.nvim_buf_get_var(buf, "terminal_job_id")
            for line in selection:gmatch("[^\n]+") do
                vim.api.nvim_chan_send(chan, line .. "\n")
            end
        end
    end
end
function M.send_buffer()
    local helper = M.get_current_config()
    if not helper then
        vim.notify("No AI helper selected. Use :AIHelperSwitch", vim.log.levels.WARN)
        return
    end

    local file = vim.fn.expand("%:p")

    local term = get_or_create_terminal(helper.cmd)
    if term then
        term:show()
        local buf = type(term.buf) == "number" and term.buf or term.buf.buf
        local chan = vim.api.nvim_buf_get_var(buf, "terminal_job_id")
        vim.api.nvim_chan_send(chan, "@" .. file .. " ")
    end
end
function M.get_helper_from_buffer(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    for helper_name, term in pairs(M.terminal_instances) do
        if term and term:valid() then
            local term_buf = type(term.buf) == "number" and term.buf or term.buf.buf
            if term_buf == bufnr then
                return helper_name
            end
        end
    end

    return nil
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
    end, { desc = "Send selection to AI helper" })

    vim.api.nvim_create_user_command("AIHelperSendBuffer", function()
        M.send_buffer()
    end, { desc = "Send current buffer to AI helper" })
end

return M
