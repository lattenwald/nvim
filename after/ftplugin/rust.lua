local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set("n", "<leader>R", "<cmd>RustLsp reloadWorkspace<CR>", { silent = true, buffer = bufnr, desc = "Reload workspace" })
vim.keymap.set("n", "<leader>a", "<cmd>RustLsp codeAction<CR>", { silent = true, buffer = bufnr, desc = "Code actions" })
vim.keymap.set("n", "<leader>A", "<cmd>RustLsp hover actions<CR>", { silent = true, buffer = bufnr, desc = "Hover action" })

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
