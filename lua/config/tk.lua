-- :Tk, a front end for the tk ticket CLI (docs/superpowers/specs/2026-09-29-tk-design.md)
local M = {}

local STATUS_ICON = { open = "○", in_progress = "◐", closed = "●" }
local STATUS_HL = { open = "Normal", in_progress = "DiagnosticWarn", closed = "SnacksPickerDimmed" }
local STATUS_GROUP = { in_progress = 1, open = 2, closed = 3 }
local PRIORITY_HL = { [0] = "DiagnosticError", "DiagnosticWarn", "Normal", "SnacksPickerComment", "SnacksPickerComment" }
local ACTIONS = {
    open = { { "Start", "start" }, { "Close", "close" }, { "Add note", "add-note" } },
    in_progress = { { "Stop", "status", "open" }, { "Close", "close" }, { "Add note", "add-note" } },
    closed = { { "Reopen", "reopen" }, { "Add note", "add-note" } },
}
-- tk 0.3.2 behaviour that `tk help` doesn't show
local OVERRIDES = {
    create = { mkdir = true, open_created = true }, -- silently creates .tickets/ in cwd; prints the new ID
    ["migrate-beads"] = { mkdir = true },
    edit = { local_edit = true }, -- without a terminal only prints the path
    ["add-note"] = { ask_text = true }, -- reads stdin, which vim.system leaves empty
}

local Failure = {}

local function fail(msg)
    error(setmetatable({ msg = msg }, Failure), 0)
end

local usages_cache

local function parse_usage(line)
    local rest = line:match("^  (%S.*)$")
    if not rest or rest:match("^%-") then
        return nil
    end
    local u = { words = {}, slots = {} }
    local pos = 1
    while true do
        local s = rest:match("^%s*()", pos)
        local c = rest:sub(s, s)
        if c == "<" or c == "[" then
            local e = rest:find(c == "<" and ">" or "]", s, true)
            if not e then
                return nil, "unclosed " .. c
            end
            local group = rest:sub(s, e)
            if group:match("^%[%-") then
                u.flags = true
                u.valued_flag = u.valued_flag or group:find(" ", 1, true) ~= nil
            elseif group ~= "[options]" then
                local name = group:sub(2, -2)
                local variadic = name:sub(-3) == "..."
                name = variadic and name:sub(1, -4) or name
                local kind = (name == "id" or name:match("%-id$")) and "id" or name == "status" and "status" or "text"
                table.insert(u.slots, { name = name, kind = kind, required = c == "<", variadic = variadic })
            end
            pos = e + 1
        else
            local w, e = rest:match("^([a-z][a-z|-]*)()", s)
            if not w or #u.slots > 0 or not rest:sub(e, e):match("^%s?$") then
                u.desc = vim.trim(rest:sub(s))
                break
            end
            table.insert(u.words, vim.split(w, "|", { plain = true }))
            pos = e
        end
    end
    if #u.words == 0 or #u.words > 2 then
        return nil, ("%d subcommand words"):format(#u.words)
    end
    if u.desc == "" then
        return nil, "empty description"
    end
    for _, slot in ipairs(u.slots) do
        if slot.kind == "id" and u.valued_flag then
            return nil, "flag with a value before an ID"
        elseif slot.kind == "status" then
            local values = u.desc:match("%(([%w_|]+)%)")
            if not values then
                return nil, "no status values in description"
            end
            slot.values = vim.split(values, "|", { plain = true })
        end
    end
    return u
end

local function usages()
    if usages_cache then
        return usages_cache
    end
    local r = vim.system({ "tk", "help" }, { text = true }):wait()
    if r.code ~= 0 then
        fail("tk help failed: " .. vim.trim(r.stderr or ""))
    end
    local list = {}
    for line in r.stdout:gmatch("[^\n]+") do
        local u, err = parse_usage(line)
        if err then
            fail(("cannot parse tk help (%s): %s"):format(err, line))
        end
        if u then
            table.insert(list, u)
        end
    end
    if #list == 0 then
        fail("cannot parse tk help: no usage lines")
    end
    usages_cache = list
    return list
end

local function words_match(u, args, n)
    for i = 1, n do
        if not vim.tbl_contains(u.words[i], args[i]) then
            return false
        end
    end
    return true
end

local function find_usage(args)
    local best
    for _, u in ipairs(usages()) do
        if #args >= #u.words and words_match(u, args, #u.words) and (not best or #u.words > #best.words) then
            best = u
        end
    end
    return best
end

local function split_flags(u, args)
    local flags, pos = {}, {}
    for _, a in ipairs(vim.list_slice(args, #u.words + 1)) do
        table.insert(u.flags and a:match("^%-.") and flags or pos, a)
    end
    return flags, pos
end

local function prefix(id)
    return id:match("^([^-]+)%-")
end

local function slot_values(u, vals, kind)
    local out = {}
    for s, slot in ipairs(u.slots) do
        if not kind or slot.kind == kind then
            local v = vals[s]
            vim.list_extend(out, type(v) == "table" and v or { v })
        end
    end
    return out
end

local function id_slots(u)
    return vim.tbl_filter(function(s)
        return s.kind == "id"
    end, u.slots)
end

local function abspath(p)
    return vim.fs.normalize(vim.fs.abspath(p))
end

local function read_ticket(path)
    local f = io.open(path)
    if not f then
        return nil
    end
    local t = { id = vim.fn.fnamemodify(path, ":t:r"), file = path }
    local fm = 0
    for line in f:lines() do
        if line == "---" then
            fm = fm + 1
        elseif fm == 1 then
            local k, v = line:match("^([%w_-]+):%s*(.-)%s*$")
            if k and k ~= "id" and k ~= "file" then
                local list = v:match("^%[(.*)%]$")
                t[k] = list and vim.split(vim.trim(list), "%s*,%s*", { trimempty = true }) or v
            end
        elseif line:match("^# ") then
            t.title = line:sub(3)
            break
        end
    end
    f:close()
    return t
end

local function read_tickets(dir)
    local tickets = {}
    for name, type in vim.fs.dir(dir or "") do
        if type == "file" and name:match("%.md$") then
            local t = read_ticket(dir .. "/" .. name)
            if t then
                tickets[t.id] = t
            end
        end
    end
    return tickets
end

local function load(dir)
    local ctx = { dir = dir, cwd = vim.fn.getcwd(), tickets = read_tickets(dir), prefixes = {}, by_hash = {} }
    if dir and vim.fs.basename(dir) == ".tickets" then
        ctx.cwd = vim.fs.dirname(dir)
    end
    ctx.env = dir and { TICKETS_DIR = dir } or nil
    for id in pairs(ctx.tickets) do
        local p = prefix(id)
        if p then
            local hash = id:sub(#p + 2)
            ctx.prefixes[p] = true
            ctx.by_hash[hash] = ctx.by_hash[hash] or {}
            table.insert(ctx.by_hash[hash], id)
        end
    end
    return ctx
end

local function context()
    local env_dir = vim.env.TICKETS_DIR and vim.env.TICKETS_DIR ~= "" and abspath(vim.env.TICKETS_DIR) or nil
    local file = vim.api.nvim_buf_get_name(0)
    local buf_dir, buf_id
    if file:match("%.md$") then
        local d = abspath(vim.fs.dirname(file))
        if vim.fs.basename(d) == ".tickets" or d == env_dir then
            buf_dir, buf_id = d, vim.fn.fnamemodify(file, ":t:r")
        end
    end
    local dir = buf_dir or env_dir or vim.fs.find(".tickets", { upward = true, type = "directory", path = vim.fn.getcwd() })[1]
    local ctx = load(dir)
    ctx.current = buf_id and ctx.tickets[buf_id] and buf_id or nil
    return ctx
end

local function resolve(ctx, arg)
    if ctx.tickets[arg] then
        return arg
    end
    local found = ctx.by_hash[arg] or {}
    if #found == 1 then
        return found[1]
    end
    return nil, #found == 0 and ("no ticket `%s`"):format(arg) or ("`%s` is ambiguous: %s"):format(arg, table.concat(found, ", "))
end

local function id_shaped(ctx, arg)
    local p = prefix(arg)
    return p ~= nil and ctx.prefixes[p] == true
end

local function split(s)
    local args, cur, quoted, started = {}, {}, false, false
    for c in s:gmatch(".") do
        if c == '"' then
            quoted, started = not quoted, true
        elseif c:match("%s") and not quoted then
            if started then
                table.insert(args, table.concat(cur))
                cur, started = {}, false
            end
        else
            table.insert(cur, c)
            started = true
        end
    end
    if quoted then
        return nil, 'unbalanced "'
    end
    if started then
        table.insert(args, table.concat(cur))
    end
    return args
end

local function takes_id(ctx, u, s, a)
    return vim.iter(vim.list_slice(u.slots, s + 1)):all(function(l)
        return l.kind == "id"
    end) or resolve(ctx, a) ~= nil or id_shaped(ctx, a)
end

local function assign(ctx, u, pos)
    local vals, skipped, owner, i = {}, {}, {}, 1
    for s, slot in ipairs(u.slots) do
        local a = pos[i]
        if slot.variadic then
            vals[s] = vim.list_slice(pos, i)
            for n = i, #pos do
                owner[n] = s
            end
            i = #pos + 1
        elseif a and (slot.kind ~= "id" or takes_id(ctx, u, s, a)) then
            vals[s], owner[i], i = a, s, i + 1
        elseif a then
            skipped[s] = true
        end
    end
    return vals, skipped, owner, vim.list_slice(pos, i)
end

local function notify_err(msg)
    vim.notify(msg, vim.log.levels.ERROR, { title = "tk" })
end

local function resume(co, ...)
    local ok, err = coroutine.resume(co, ...)
    if not ok then
        notify_err(getmetatable(err) == Failure and err.msg or debug.traceback(co, tostring(err)))
    end
end

local function run_flow(fn)
    resume(coroutine.create(fn))
end

-- Resumes on the next tick: the callback may fire synchronously
local function await(start)
    local co = coroutine.running()
    start(function(...)
        local res = { n = select("#", ...), ... }
        vim.schedule(function()
            resume(co, unpack(res, 1, res.n))
        end)
    end)
    return coroutine.yield()
end

local function cancelled()
    coroutine.yield()
end

local function show_output(title, out)
    local lines = vim.split(vim.trim(out), "\n")
    if #lines <= 1 then
        vim.notify(lines[1] ~= "" and title .. ": " .. lines[1] or title, vim.log.levels.INFO, { title = "tk" })
        return
    end
    Snacks.win({
        text = lines,
        ft = "markdown",
        title = " " .. title .. " ",
        border = "rounded",
        width = 0.8,
        height = 0.8,
        wo = { wrap = true },
        bo = { modifiable = false },
    })
end

local function run_tk(ctx, argv, on_ok)
    local title = "tk " .. table.concat(argv, " ")
    vim.system(
        vim.list_extend({ "tk" }, argv),
        { cwd = ctx.cwd, env = ctx.env, text = true },
        vim.schedule_wrap(function(r)
            if r.code ~= 0 then
                return notify_err(title .. "\n" .. vim.trim(r.stderr ~= "" and r.stderr or r.stdout))
            end
            if on_ok then
                on_ok(r.stdout)
            else
                show_output(title, r.stdout)
            end
        end)
    )
end

local function items(ctx, exclude)
    local tickets = read_tickets(ctx.dir)
    local ret = {}
    for id, t in pairs(tickets) do
        if not (exclude and exclude[id]) then
            local status = STATUS_GROUP[t.status] and t.status or "open"
            local blocked = false
            if status ~= "closed" then
                for _, dep in ipairs(type(t.deps) == "table" and t.deps or {}) do
                    blocked = blocked or not (tickets[dep] and tickets[dep].status == "closed")
                end
            end
            local tags = type(t.tags) == "table" and t.tags or {}
            table.insert(ret, {
                id = id,
                file = t.file,
                status = status,
                blocked = blocked,
                group = STATUS_GROUP[status],
                priority = tonumber(t.priority) or 2,
                created = t.created or "",
                type = t.type or "",
                title = t.title or "",
                tags = tags,
                text = table.concat({ id, t.title or "", status, blocked and "blocked" or "", t.type or "", table.concat(tags, " ") }, " "),
            })
        end
    end
    return ret
end

local function format(item)
    local closed = item.status == "closed"
    local blocked_open = item.blocked and item.status == "open"
    local ret = {
        { (blocked_open and "⊘" or STATUS_ICON[item.status]) .. " ", blocked_open and "DiagnosticError" or STATUS_HL[item.status] },
        { ("P%d "):format(item.priority), closed and "SnacksPickerDimmed" or PRIORITY_HL[item.priority] or "Normal" },
        { ("%-7s "):format(item.type), closed and "SnacksPickerDimmed" or "SnacksPickerComment" },
        { item.id .. "  ", "SnacksPickerDimmed" },
        { item.title, closed and "SnacksPickerDimmed" or "Normal" },
    }
    if #item.tags > 0 then
        table.insert(ret, { "  " .. table.concat(item.tags, " "), "SnacksPickerComment" })
    end
    return ret
end

local function preview(pctx)
    -- Snacks renders `ft = "markdown"` itself, without treesitter
    local job = Snacks.picker.preview.cmd({ "tk", "show", pctx.item.id }, pctx, { term = false, env = pctx.picker.opts.tk_ctx.env })
    pcall(vim.treesitter.start, job.buf, "markdown")
    return job
end

local function picker_opts(ctx, opts)
    return vim.tbl_extend("force", {
        title = "Tickets",
        tk_ctx = { dir = ctx.dir, env = ctx.env },
        cwd = ctx.cwd,
        finder = function()
            return items(ctx, opts.exclude)
        end,
        format = format,
        preview = preview,
        sort = { fields = { "score:desc", "group", "priority", "created:desc", "id" } },
        matcher = { sort_empty = true },
    }, opts.picker or {})
end

-- refresh() alone keeps the row, not the ticket
local function refresh(picker, id)
    if picker.closed then
        return
    end
    picker.list:set_selected()
    picker:find({
        on_done = function()
            for item, idx in picker:iter() do
                if item.id == id then
                    picker.list:view(idx)
                    return
                end
            end
        end,
    })
end

local dispatch

local function ticket_actions(picker, item)
    if not item then
        return
    end
    local ctx = picker.opts.tk_ctx
    vim.ui.select(ACTIONS[item.status], {
        prompt = item.id,
        format_item = function(e)
            return e[1]
        end,
    }, function(e)
        if not e then
            return
        end
        local args = { e[2], item.id, e[3] }
        run_flow(function()
            dispatch(load(ctx.dir), args, function()
                refresh(picker, item.id)
            end)
        end)
    end)
end

local function browse(ctx)
    if not ctx.dir then
        fail("no .tickets directory found")
    end
    Snacks.picker.pick(picker_opts(ctx, {
        picker = {
            actions = { tk_actions = ticket_actions },
            win = {
                input = { keys = { ["<a-a>"] = { "tk_actions", mode = { "n", "i" } } } },
                list = { keys = { ["<a-a>"] = "tk_actions" } },
            },
        },
    }))
end

local function pick_ids(ctx, title, exclude, multi)
    return await(function(cb)
        local done = false
        Snacks.picker.pick(picker_opts(ctx, {
            exclude = exclude,
            picker = {
                title = title,
                confirm = function(picker, item)
                    local sel = multi and picker:selected({ fallback = true }) or { item }
                    local ids = vim.tbl_map(function(i)
                        return i.id
                    end, sel)
                    done = true
                    picker:close()
                    cb(#ids > 0 and ids or nil)
                end,
                on_close = function()
                    if not done then
                        cb(nil)
                    end
                end,
            },
        }))
    end)
end

local function passthrough(ctx, args)
    local o = OVERRIDES[args[1]] or {}
    local dir = ctx.dir
    if not dir and o.mkdir then
        dir = ctx.cwd .. "/.tickets"
        local choice = await(function(cb)
            vim.ui.select({ "Create", "Cancel" }, { prompt = ("Create .tickets/ in %s?"):format(dir) }, cb)
        end)
        if choice ~= "Create" then
            cancelled()
        end
    end
    run_tk(ctx, args, o.open_created and function(out)
        vim.cmd.edit(vim.fn.fnameescape(dir .. "/" .. vim.trim(out) .. ".md"))
    end or nil)
end

local function command_title(u, vals)
    local parts = { "tk" }
    for _, alts in ipairs(u.words) do
        table.insert(parts, alts[1])
    end
    return table.concat(vim.list_extend(parts, slot_values(u, vals)), " ")
end

local function fill_ids(ctx, u, vals, used)
    local slots = id_slots(u)
    local variadic = slots[#slots].variadic and slots[#slots]
    local missing = {}
    for s, slot in ipairs(u.slots) do
        if slot.kind == "id" and not slot.variadic and not vals[s] then
            table.insert(missing, s)
        end
    end
    if #missing == 0 then
        return
    end
    if variadic then
        local title = ("%s ‹%s›…"):format(command_title(u, vals), variadic.name)
        local picked = pick_ids(ctx, title, used, true) or cancelled()
        if #picked < #missing then
            fail(("%s needs %d more tickets, picked %d"):format(command_title(u, vals), #missing, #picked))
        end
        for n, s in ipairs(missing) do
            vals[s] = picked[n]
        end
        local tail = vals[#u.slots]
        vim.list_extend(tail, vim.list_slice(picked, #missing + 1))
        return
    end
    for _, s in ipairs(missing) do
        local title = ("%s ‹%s›"):format(command_title(u, vals), u.slots[s].name)
        vals[s] = #slots == 1 and ctx.current or (pick_ids(ctx, title, used) or cancelled())[1]
        used[vals[s]] = true
    end
end

local function check_unique(u, vals)
    local seen = {}
    for _, id in ipairs(slot_values(u, vals, "id")) do
        if seen[id] then
            fail(("%s: %s given twice"):format(command_title(u, vals), id))
        end
        seen[id] = true
    end
    return seen
end

function dispatch(ctx, args, on_ok)
    local u = find_usage(args)
    if not u or #id_slots(u) == 0 then
        return passthrough(ctx, args)
    end
    if not ctx.dir then
        fail("no .tickets directory found")
    end
    local o = OVERRIDES[args[1]] or {}
    local words = vim.list_slice(args, 1, #u.words)
    local flags, pos = split_flags(u, args)

    local vals, _, _, rest = assign(ctx, u, pos)
    local function must_resolve(a)
        local id, err = resolve(ctx, a)
        return id or fail(err)
    end
    for s, slot in ipairs(u.slots) do
        local v = vals[s]
        if slot.kind == "id" and type(v) == "table" then
            vals[s] = vim.tbl_map(must_resolve, v)
        elseif slot.kind == "id" and v then
            vals[s] = must_resolve(v)
        elseif slot.kind == "status" and v and not vim.tbl_contains(slot.values, v) then
            fail(("invalid status `%s`, expected one of: %s"):format(v, table.concat(slot.values, ", ")))
        end
    end

    fill_ids(ctx, u, vals, check_unique(u, vals))

    for s, slot in ipairs(u.slots) do
        if not vals[s] and slot.kind == "status" then
            vals[s] = await(function(cb)
                vim.ui.select(slot.values, { prompt = command_title(u, vals) }, cb)
            end) or cancelled()
        elseif not vals[s] and slot.kind == "text" and o.ask_text then
            local note = await(function(cb)
                vim.ui.input({ prompt = command_title(u, vals) .. ": " }, cb)
            end)
            vals[s] = note ~= "" and note or cancelled()
        end
    end

    if o.local_edit then
        return vim.cmd.edit(vim.fn.fnameescape(ctx.dir .. "/" .. slot_values(u, vals, "id")[1] .. ".md"))
    end
    run_tk(ctx, vim.list_extend(vim.list_extend(vim.list_extend(words, flags), slot_values(u, vals)), rest), on_ok)
end

local function command(opts)
    run_flow(function()
        local ctx = context()
        local args, err = split(opts.args)
        if not args then
            fail(err)
        end
        usages()
        if #args == 0 then
            return browse(ctx)
        end
        dispatch(ctx, args)
    end)
end

-- blink.cmp completes on every keystroke
local comp

local function matching_ids(ctx, lead)
    local ret = {}
    for id in pairs(ctx.tickets) do
        local p = prefix(id)
        if vim.startswith(id, lead) or (p and vim.startswith(id:sub(#p + 2), lead)) then
            table.insert(ret, id)
        end
    end
    table.sort(ret)
    return ret
end

local function matching(list, lead)
    return vim.tbl_filter(function(v)
        return vim.startswith(v, lead)
    end, list)
end

local function slot_candidates(ctx, u, pos, lead)
    local _, skipped, owner = assign(ctx, u, vim.list_extend(pos, { lead }))
    local target = owner[#pos]
    if not target then
        return {}
    end
    local slot = u.slots[target]
    if slot.kind == "id" then
        return matching_ids(ctx, lead)
    end
    local ret = slot.kind == "status" and matching(slot.values, lead) or {}
    if skipped[target - 1] and (lead == "" or #ret == 0) then
        vim.list_extend(ret, matching_ids(ctx, lead))
    end
    return ret
end

local function complete(lead, line, cursor)
    if not comp then
        local ok, err = pcall(usages)
        comp = { ok = ok, ctx = context() }
        if not ok then
            notify_err(getmetatable(err) == Failure and err.msg or tostring(err))
        end
    end
    local before = line:sub(1, cursor):match("^%s*%S+%s*(.*)$") or ""
    local args = split(before:sub(1, #before - #lead))
    if not comp.ok or not args then
        return {}
    end
    local ret = {}
    for _, u in ipairs(usages()) do
        if #u.words > #args and words_match(u, args, #args) then
            vim.list_extend(ret, matching(u.words[#args + 1], lead))
        end
    end
    local u = find_usage(args)
    if u then
        local _, pos = split_flags(u, args)
        vim.list_extend(ret, slot_candidates(comp.ctx, u, pos, lead))
    end
    return vim.list.unique(ret)
end

function M.setup()
    if vim.fn.executable("tk") == 0 then
        return
    end
    vim.api.nvim_create_user_command("Tk", command, { nargs = "*", complete = complete, desc = "tk tickets" })
    vim.api.nvim_create_autocmd("CmdlineLeave", {
        group = vim.api.nvim_create_augroup("tk_completion", { clear = true }),
        callback = function()
            comp = nil
        end,
    })
end

return M
