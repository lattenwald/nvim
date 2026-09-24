-- Corporate npm mirror may lack the exact version Mason pins; install its latest instead
local M = {}

function M.setup()
    local spawn = require("mason-core.spawn")
    local compiler = require("mason-core.installer.compiler.compilers.npm")
    local install = compiler.install
    assert(type(install) == "function", "mason_npm_fallback: npm compiler has no install()")

    compiler.install = function(ctx, source, purl)
        assert(
            type(source.package) == "string" and purl and source.version == purl.version,
            "mason_npm_fallback: unexpected npm source shape, update or remove the patch"
        )

        if not ctx.opts.version then
            local wanted = ("%s@%s"):format(source.package, source.version)
            local err = spawn.npm({ "view", wanted, "version" }):err_or_nil()
            if err and (err.stderr or ""):find("E404", 1, true) then
                local latest = spawn.npm({ "view", source.package, "version" }):get_or_nil()
                latest = latest and vim.trim(latest.stdout or "")
                if latest and latest ~= "" then
                    local msg = ("%s is not on the npm mirror, installing %s"):format(wanted, latest)
                    ctx.stdio_sink:stderr(msg .. "\n")
                    vim.schedule(function()
                        vim.notify(msg, vim.log.levels.WARN, { title = "Mason" })
                    end)
                    source.version = latest
                    purl.version = latest
                end
            end
        end

        return install(ctx, source, purl)
    end
end

return M
