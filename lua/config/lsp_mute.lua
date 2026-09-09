-- Mute LSP diagnostics per client by severity or code via a wrapped vim.diagnostic.set,
-- so muted diagnostics disappear everywhere (signs, virtual text, pickers, statusline).
-- vim.diagnostic.config() can't do this: it never reaches vim.diagnostic.get().
local M = {}

-- Indexed by severity: vim.diagnostic.severity is 1-4 in this order
local SEVERITIES = { "ERROR", "WARN", "INFO", "HINT" }

-- muted[client_name][key] = true, key is "sev:<severity>" or "code:<code>"; empty clients are dropped
local muted = {}

-- Unfiltered diagnostics per namespace+buffer, so unmuting restores instantly
-- without waiting for the server to republish
local cache = {}

-- namespace id -> client name (false = not an LSP namespace)
local ns_client = {}

local orig_set = vim.diagnostic.set

-- LSP namespaces are named "nvim.lsp.<client_name>.<client_id>[.provider]"
local function client_name_for_ns(ns)
    if ns_client[ns] == nil then
        -- get_namespace registers on first use; asserts on anonymous namespaces
        local ok, info = pcall(vim.diagnostic.get_namespace, ns)
        ns_client[ns] = ok and info.name:match("^nvim%.lsp%.(.-)%.%d+") or false
    end
    return ns_client[ns] or nil
end

local function sev_key(severity)
    return "sev:" .. severity
end

local function code_key(code)
    return "code:" .. tostring(code)
end

-- LSP code is optional and a JSON null decodes to vim.NIL
local function code_of(d)
    if d.code ~= nil and d.code ~= vim.NIL then
        return d.code
    end
end

local function mute_keys(d)
    -- LSP severity is optional; orig_set defaults it to ERROR only after we filter
    local keys = { sev_key(d.severity or vim.diagnostic.severity.ERROR) }
    local code = code_of(d)
    if code ~= nil then
        keys[#keys + 1] = code_key(code)
    end
    return keys
end

local function filter(name, diagnostics)
    local m = muted[name]
    if not m then
        return diagnostics
    end
    return vim.tbl_filter(function(d)
        for _, key in ipairs(mute_keys(d)) do
            if m[key] then
                return false
            end
        end
        return true
    end, diagnostics)
end

local function wrapped_set(ns, bufnr, diagnostics, opts)
    local name = client_name_for_ns(ns)
    if name then
        cache[ns] = cache[ns] or {}
        cache[ns][bufnr] = diagnostics
        diagnostics = filter(name, diagnostics)
    end
    return orig_set(ns, bufnr, diagnostics, opts)
end

-- update_in_insert: picker input is insert mode, and show()'s deferral waits for InsertLeave in the code buffer
local function reapply(name)
    for ns, client in pairs(ns_client) do
        if client == name and cache[ns] then
            for bufnr, diags in pairs(cache[ns]) do
                if vim.api.nvim_buf_is_valid(bufnr) then
                    orig_set(ns, bufnr, filter(name, diags), { update_in_insert = true })
                else
                    cache[ns][bufnr] = nil
                end
            end
        end
    end
end

-- counts[client_name][key] = { count, severity, messages = { [msg] = n }, href }, muted included
local function diagnostic_counts()
    local counts = {}
    for ns, bufs in pairs(cache) do
        local name = ns_client[ns]
        if name then
            counts[name] = counts[name] or {}
            for bufnr, diags in pairs(bufs) do
                if vim.api.nvim_buf_is_valid(bufnr) then
                    for _, d in ipairs(diags) do
                        local msg = d.message:match("^[^\n]*")
                        local lsp = d.user_data and d.user_data.lsp
                        local href = lsp and lsp.codeDescription and lsp.codeDescription.href
                        for _, key in ipairs(mute_keys(d)) do
                            local entry = counts[name][key] or { count = 0, severity = d.severity, messages = {} }
                            entry.count = entry.count + 1
                            entry.severity = math.min(entry.severity, d.severity)
                            entry.messages[msg] = (entry.messages[msg] or 0) + 1
                            if key:sub(1, 5) == "code:" then
                                entry.href = entry.href or href
                            end
                            counts[name][key] = entry
                        end
                    end
                end
            end
        end
    end
    return counts
end

local PREVIEW_MESSAGES = 15

local function preview_text(entry)
    if not entry then
        return "No diagnostics currently cached"
    end
    local lines = {}
    if entry.href then
        table.insert(lines, entry.href)
        table.insert(lines, "")
    end
    local msgs = vim.tbl_keys(entry.messages)
    table.sort(msgs, function(a, b)
        if entry.messages[a] ~= entry.messages[b] then
            return entry.messages[a] > entry.messages[b]
        end
        return a < b
    end)
    for i = 1, math.min(#msgs, PREVIEW_MESSAGES) do
        table.insert(lines, ("%4d  %s"):format(entry.messages[msgs[i]], msgs[i]))
    end
    if #msgs > PREVIEW_MESSAGES then
        table.insert(lines, ("      … %d more distinct messages"):format(#msgs - PREVIEW_MESSAGES))
    end
    return table.concat(lines, "\n")
end

function M.is_muted(name, key)
    return muted[name] and muted[name][key] or false
end

-- Rebuilt on toggle only; lualine calls the component on every redraw
local status = ""

local function rebuild_status()
    local names = vim.tbl_keys(muted)
    table.sort(names)

    local parts = {}
    for _, name in ipairs(names) do
        local letters, ncodes = {}, 0
        for severity, sev in ipairs(SEVERITIES) do
            if M.is_muted(name, sev_key(severity)) then
                table.insert(letters, sev:sub(1, 1))
            end
        end
        for key in pairs(muted[name]) do
            if key:sub(1, 5) == "code:" then
                ncodes = ncodes + 1
            end
        end
        local suffix = ncodes > 0 and ("+" .. ncodes) or ""
        table.insert(parts, name .. ":" .. table.concat(letters) .. suffix)
    end

    status = #parts > 0 and ("󰖁 " .. table.concat(parts, " ")) or ""
end

function M.toggle(name, key)
    local m = muted[name] or {}
    m[key] = not m[key] or nil
    muted[name] = next(m) ~= nil and m or nil
    reapply(name)
    rebuild_status()
end

-- Mute only: muted diagnostics are invisible to vim.diagnostic.get, unmute via the picker
function M.mute_code_at_cursor()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local col = cursor[2]
    local target
    for _, d in ipairs(vim.diagnostic.get(0, { lnum = cursor[1] - 1 })) do
        if code_of(d) ~= nil and client_name_for_ns(d.namespace) then
            target = target or d
            if col >= d.col and col < d.end_col then
                target = d
                break
            end
        end
    end
    if not target then
        vim.notify("No diagnostic with a code under cursor", vim.log.levels.WARN)
        return
    end
    local name = client_name_for_ns(target.namespace)
    M.toggle(name, code_key(target.code))
    vim.notify(("Muted %s: %s"):format(name, target.code))
end

function M.pick()
    Snacks.picker.pick({
        title = "Mute LSP Diagnostics",
        finder = function()
            -- Include stopped clients with mutes
            local seen = {}
            for name in pairs(muted) do
                seen[name] = true
            end
            for _, client in ipairs(vim.lsp.get_clients()) do
                seen[client.name] = true
            end
            local names = vim.tbl_keys(seen)
            table.sort(names)

            local counts = diagnostic_counts()
            local items = {}
            for _, name in ipairs(names) do
                local c = counts[name] or {}
                for severity, sev in ipairs(SEVERITIES) do
                    local key = sev_key(severity)
                    table.insert(items, {
                        text = name .. " " .. sev,
                        client = name,
                        key = key,
                        label = sev,
                        severity = severity,
                        count = c[key] and c[key].count or 0,
                        preview = { text = preview_text(c[key]), loc = false },
                    })
                end
                -- Include muted codes with no live diagnostics
                local codes = {}
                for key in pairs(vim.tbl_extend("keep", c, muted[name] or {})) do
                    if key:sub(1, 5) == "code:" then
                        table.insert(codes, key)
                    end
                end
                local function count(key)
                    return c[key] and c[key].count or 0
                end
                table.sort(codes, function(a, b)
                    if count(a) ~= count(b) then
                        return count(a) > count(b)
                    end
                    return a < b
                end)
                for _, key in ipairs(codes) do
                    table.insert(items, {
                        text = name .. " " .. key:sub(6),
                        client = name,
                        key = key,
                        label = key:sub(6),
                        severity = c[key] and c[key].severity,
                        count = count(key),
                        preview = { text = preview_text(c[key]), loc = false },
                    })
                end
            end
            return items
        end,
        format = function(item)
            local sev = SEVERITIES[item.severity]
            local hl = sev and ("Diagnostic" .. sev:sub(1, 1) .. sev:sub(2):lower()) or "Comment"
            return {
                { ("%-20s"):format(item.client) },
                { ("%-20s"):format(item.label), hl },
                { ("%5s"):format(item.count > 0 and tostring(item.count) or ""), "Number" },
                { M.is_muted(item.client, item.key) and " 󰖁 muted" or "", "Comment" },
            }
        end,
        preview = "preview",
        layout = { preset = "vertical" },
        confirm = function(picker, item)
            if item then
                M.toggle(item.client, item.key)
                -- find() resets the list cursor
                local cursor = picker.list.cursor
                picker:find({
                    on_done = function()
                        picker.list:view(cursor)
                    end,
                })
            end
        end,
    })
end

function M.lualine_component()
    return status
end

function M.setup()
    if vim.diagnostic.set == wrapped_set then
        return
    end
    vim.diagnostic.set = wrapped_set

    vim.api.nvim_create_autocmd("BufWipeout", {
        group = vim.api.nvim_create_augroup("LspMute", { clear = true }),
        callback = function(ev)
            for _, bufs in pairs(cache) do
                bufs[ev.buf] = nil
            end
        end,
    })
end

return M
