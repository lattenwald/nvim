vim.keymap.set("n", "<leader>R", function() vim.cmd.RustLsp('reloadWorkspace') end, { silent = true, buffer = true, desc = 'Reload workspace' })
vim.keymap.set("n", "<leader>a", function() vim.cmd.RustLsp('codeAction') end, { silent = true, buffer = true, desc = 'Rust code actions', remap = true })
vim.keymap.set("n", "<leader>A", function() vim.cmd.RustLsp{'hover', 'actions'} end, { silent = true, buffer = true, desc = 'Rust hover action' })
vim.keymap.set('n', '<C-f5>',  function() vim.cmd.RustLsp('debug') end, {silent = true, buffer = true, desc = 'RustLsp debug'})
vim.keymap.set('n', '<C-S-f5>',  function() vim.cmd.RustLsp{'debug', bang = true} end, {silent = true, buffer = true, desc = 'RustLsp debug!'})

vim.g.rustaceanvim = function()
  -- Update this path
  local extension_path = '/usr/lib/codelldb/'
  local codelldb_path = extension_path .. 'adapter/codelldb'
  local liblldb_path = extension_path .. 'lldb/lib/liblldb'
  local this_os = vim.loop.os_uname().sysname;

  -- The path is different on Windows
  if this_os:find "Windows" then
    codelldb_path = extension_path .. "adapter\\codelldb.exe"
    liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
  else
    -- The liblldb extension is .so for Linux and .dylib for MacOS
    liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
  end

  local cfg = require('rustaceanvim.config')
  return {
    dap = {
      adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
    },
  }
end
