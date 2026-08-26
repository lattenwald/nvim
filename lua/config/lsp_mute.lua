-- Mute LSP diagnostics per client and severity via a wrapped vim.diagnostic.set,
-- so muted diagnostics disappear everywhere (signs, virtual text, pickers, statusline).
-- vim.diagnostic.config() can't do this: it never reaches vim.diagnostic.get().
local M = {}

-- Indexed by severity: vim.diagnostic.severity is 1-4 in this order
local SEVERITIES = { "ERROR", "WARN", "INFO", "HINT" }

-- muted[client_name][severity] = true; a client with nothing muted is dropped entirely
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
        local info = vim.diagnostic.get_namespaces()[ns]
        ns_client[ns] = info and info.name and info.name:match("^nvim%.lsp%.(.-)%.%d+") or false
    end
    return ns_client[ns] or nil
end

local function filter(name, diagnostics)
    local m = muted[name]
    if not m then
        return diagnostics
    end
    return vim.tbl_filter(function(d)
        return not m[d.severity]
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

local function reapply(name)
    for ns, client in pairs(ns_client) do
        if client == name and cache[ns] then
            for bufnr, diags in pairs(cache[ns]) do
                if vim.api.nvim_buf_is_valid(bufnr) then
                    orig_set(ns, bufnr, filter(name, diags))
                else
                    cache[ns][bufnr] = nil
                end
            end
        end
    end
end

-- counts[client_name][severity] from cached unfiltered diagnostics, so muted ones are included
local function diagnostic_counts()
    local counts = {}
    for ns, bufs in pairs(cache) do
        local name = ns_client[ns]
        if name then
            counts[name] = counts[name] or {}
            for bufnr, diags in pairs(bufs) do
                if vim.api.nvim_buf_is_valid(bufnr) then
                    for _, d in ipairs(diags) do
                        counts[name][d.severity] = (counts[name][d.severity] or 0) + 1
                    end
                end
            end
        end
    end
    return counts
end

function M.is_muted(name, severity)
    return muted[name] and muted[name][severity] or false
end

-- Rebuilt on toggle only; lualine calls the component on every redraw
local status = ""

local function rebuild_status()
    local names = vim.tbl_keys(muted)
    table.sort(names)

    local parts = {}
    for _, name in ipairs(names) do
        local letters = {}
        for severity, sev in ipairs(SEVERITIES) do
            if M.is_muted(name, severity) then
                table.insert(letters, sev:sub(1, 1))
            end
        end
        table.insert(parts, name .. ":" .. table.concat(letters))
    end

    status = #parts > 0 and ("󰖁 " .. table.concat(parts, " ")) or ""
end

function M.toggle(name, severity)
    local m = muted[name] or {}
    m[severity] = not m[severity] or nil
    muted[name] = next(m) ~= nil and m or nil
    reapply(name)
    rebuild_status()
end

function M.pick()
    Snacks.picker.pick({
        title = "Mute LSP Diagnostics",
        finder = function()
            local seen = {}
            for _, client in ipairs(vim.lsp.get_clients()) do
                seen[client.name] = true
            end
            local names = vim.tbl_keys(seen)
            table.sort(names)

            local counts = diagnostic_counts()
            local items = {}
            for _, name in ipairs(names) do
                for severity, sev in ipairs(SEVERITIES) do
                    table.insert(items, {
                        text = name .. " " .. sev,
                        client = name,
                        severity = severity,
                        count = counts[name] and counts[name][severity] or 0,
                    })
                end
            end
            return items
        end,
        format = function(item)
            local sev = SEVERITIES[item.severity]
            local hl = "Diagnostic" .. sev:sub(1, 1) .. sev:sub(2):lower()
            return {
                { ("%-20s"):format(item.client) },
                { ("%-6s"):format(sev), hl },
                { ("%5s"):format(item.count > 0 and tostring(item.count) or ""), "Number" },
                { M.is_muted(item.client, item.severity) and " 󰖁 muted" or "", "Comment" },
            }
        end,
        layout = { preset = "select" },
        confirm = function(picker, item)
            if item then
                M.toggle(item.client, item.severity)
                picker:find()
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
