return {
    {
        name = "window-focus-indicator",
        dir = vim.fn.stdpath("config"),
        event = "VeryLazy",
        opts = {
            enable_dimming = true, -- Dim unfocused windows
            dimming_amount = 0.85, -- 0.0 (darkest) to 1.0 (no dimming), 0.85 = 15% darker
            enable_border = true, -- Add border to focused window
            border_style = "rounded", -- "none", "single", "double", "rounded", "solid", "shadow"
            border_hl = "FloatBorder", -- Highlight group for focused window border
        },
        config = function(_, opts)
            -- Merge with defaults
            opts = vim.tbl_deep_extend("force", {
                enable_dimming = true,
                dimming_amount = 0.85,
                enable_border = true,
                border_style = "rounded",
                border_hl = "FloatBorder",
            }, opts or {})

            local group = vim.api.nvim_create_augroup("WindowFocusIndicator", { clear = true })

            -- Window dimming setup
            if opts.enable_dimming then
                vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
                    group = group,
                    callback = function()
                        vim.wo.winhighlight = ""
                    end,
                    desc = "Remove dimming from focused window",
                })

                vim.api.nvim_create_autocmd({ "WinLeave" }, {
                    group = group,
                    callback = function()
                        vim.wo.winhighlight = "Normal:NormalNC"
                    end,
                    desc = "Dim unfocused windows",
                })

                -- Enhance NormalNC highlight if theme doesn't define it well
                local function ensure_normal_nc()
                    local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
                    local normal_nc = vim.api.nvim_get_hl(0, { name = "NormalNC" })

                    if not normal_nc.bg or normal_nc.bg == normal.bg then
                        if normal.bg then
                            local function dim_color(color, amount)
                                if not color then
                                    return nil
                                end
                                local r = math.floor(bit.rshift(bit.band(color, 0xff0000), 16) * amount)
                                local g = math.floor(bit.rshift(bit.band(color, 0x00ff00), 8) * amount)
                                local b = math.floor(bit.band(color, 0x0000ff) * amount)
                                return bit.bor(bit.lshift(r, 16), bit.bor(bit.lshift(g, 8), b))
                            end

                            vim.api.nvim_set_hl(0, "NormalNC", {
                                bg = dim_color(normal.bg, opts.dimming_amount),
                                fg = normal.fg,
                            })
                        end
                    end
                end

                ensure_normal_nc()

                vim.api.nvim_create_autocmd("ColorScheme", {
                    group = group,
                    callback = ensure_normal_nc,
                    desc = "Ensure NormalNC is dimmed after colorscheme change",
                })

                -- Apply to all existing windows on startup
                vim.schedule(function()
                    local current_win = vim.api.nvim_get_current_win()
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        if win ~= current_win then
                            vim.wo[win].winhighlight = "Normal:NormalNC"
                        end
                    end
                end)
            end

            -- Window border setup
            if opts.enable_border then
                -- Create highlight group for focused window border if it doesn't exist
                local function setup_border_highlights()
                    -- Use the specified highlight or fall back to FloatBorder
                    if not pcall(vim.api.nvim_get_hl, 0, { name = "FocusedWindowBorder" }) then
                        local border_hl = vim.api.nvim_get_hl(0, { name = opts.border_hl })
                        vim.api.nvim_set_hl(0, "FocusedWindowBorder", border_hl)
                    end
                end

                setup_border_highlights()

                vim.api.nvim_create_autocmd("ColorScheme", {
                    group = group,
                    callback = setup_border_highlights,
                    desc = "Update border highlights after colorscheme change",
                })

                -- Track border namespace
                local border_ns = vim.api.nvim_create_namespace("window_focus_border")

                local function clear_border(win)
                    if vim.api.nvim_win_is_valid(win) then
                        pcall(vim.api.nvim_win_set_config, win, { border = "none" })
                    end
                end

                local function set_border(win)
                    if vim.api.nvim_win_is_valid(win) then
                        local config = vim.api.nvim_win_get_config(win)
                        -- Only add border to normal splits, not floating windows
                        if config.relative == "" then
                            pcall(vim.api.nvim_win_set_config, win, {
                                border = opts.border_style,
                            })
                        end
                    end
                end

                vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
                    group = group,
                    callback = function()
                        local current_win = vim.api.nvim_get_current_win()
                        -- Clear borders from all other windows
                        for _, win in ipairs(vim.api.nvim_list_wins()) do
                            if win ~= current_win then
                                clear_border(win)
                            end
                        end
                        -- Set border on focused window
                        set_border(current_win)
                    end,
                    desc = "Add border to focused window",
                })

                vim.api.nvim_create_autocmd({ "WinLeave" }, {
                    group = group,
                    callback = function(ev)
                        clear_border(vim.api.nvim_get_current_win())
                    end,
                    desc = "Remove border from unfocused window",
                })

                -- Apply border to current window on startup
                vim.schedule(function()
                    set_border(vim.api.nvim_get_current_win())
                end)
            end
        end,
    },
}
