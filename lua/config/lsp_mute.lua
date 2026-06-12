-- Mute LSP diagnostics per client and severity via a wrapped vim.diagnostic.set,
-- so muted diagnostics disappear everywhere (signs, virtual text, pickers, statusline)
local M = {}

local SEVERITIES = { "ERROR", "WARN", "INFO", "HINT" }

-- muted[client_name][severity] = true
local muted = {}

-- Unfiltered diagnostics per namespace+buffer, so unmuting restores instantly
-- without waiting for the server to republish
local cache = {}

-- namespace id -> client name (false = not an LSP namespace)
local ns_client = {}

local orig_set = vim.diagnostic.set

-- LSP namespaces are named "nvim.lsp.<client_name>.<client_id>[.provider]"
local function client_name_for_ns(ns)
    if ns_client[ns] ~= nil then
        return ns_client[ns] or nil
    end
    local info = vim.diagnostic.get_namespaces()[ns]
    local ns_name = info and info.name or ""
    for _, client in ipairs(vim.lsp.get_clients()) do
        local prefix = ("nvim.lsp.%s.%d"):format(client.name, client.id)
        if ns_name == prefix or vim.startswith(ns_name, prefix .. ".") then
            ns_client[ns] = client.name
            return client.name
        end
    end
    ns_client[ns] = false
end

local function filter(name, diagnostics)
    local m = muted[name]
    if not m or next(m) == nil then
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
            local c = counts[name] or {}
            counts[name] = c
            for bufnr, diags in pairs(bufs) do
                if vim.api.nvim_buf_is_valid(bufnr) then
                    for _, d in ipairs(diags) do
                        c[d.severity] = (c[d.severity] or 0) + 1
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

function M.toggle(name, severity)
    muted[name] = muted[name] or {}
    muted[name][severity] = not muted[name][severity] and true or nil
    reapply(name)
end

function M.pick()
    require("snacks").picker.pick({
        title = "Mute LSP Diagnostics",
        finder = function()
            local seen, names, items = {}, {}, {}
            for _, client in ipairs(vim.lsp.get_clients()) do
                if not seen[client.name] then
                    seen[client.name] = true
                    table.insert(names, client.name)
                end
            end
            table.sort(names)
            local counts = diagnostic_counts()
            for _, name in ipairs(names) do
                for _, sev in ipairs(SEVERITIES) do
                    local severity = vim.diagnostic.severity[sev]
                    table.insert(items, {
                        text = name .. " " .. sev,
                        client = name,
                        severity = severity,
                        sev = sev,
                        count = counts[name] and counts[name][severity] or 0,
                    })
                end
            end
            return items
        end,
        format = function(item)
            local hl = "Diagnostic" .. item.sev:sub(1, 1) .. item.sev:sub(2):lower()
            return {
                { ("%-20s"):format(item.client) },
                { ("%-6s"):format(item.sev), hl },
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
    local names = vim.tbl_keys(muted)
    table.sort(names)
    local parts = {}
    for _, name in ipairs(names) do
        local letters = {}
        for _, sev in ipairs(SEVERITIES) do
            if muted[name][vim.diagnostic.severity[sev]] then
                table.insert(letters, sev:sub(1, 1))
            end
        end
        if #letters > 0 then
            table.insert(parts, name .. ":" .. table.concat(letters))
        end
    end
    if #parts == 0 then
        return ""
    end
    return "󰖁 " .. table.concat(parts, " ")
end

local installed = false

function M.setup()
    if installed then
        return
    end
    installed = true
    vim.diagnostic.set = wrapped_set
    vim.api.nvim_create_autocmd("BufWipeout", {
        callback = function(ev)
            for _, bufs in pairs(cache) do
                bufs[ev.buf] = nil
            end
        end,
    })
end

return M
