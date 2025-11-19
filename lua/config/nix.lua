local function setup_nix_lua_paths()
  local home = os.getenv("HOME")
  local nix_profile = home .. "/.nix-profile"

  -- Check if Nix profile exists
  local nix_lua_path = nix_profile .. "/share/lua/5.1"
  local nix_lua_cpath = nix_profile .. "/lib/lua/5.1"

  local f = io.open(nix_lua_path, "r")
  if f ~= nil then
    io.close(f)
    -- Add Nix paths
    package.path = package.path .. ';' .. nix_lua_path .. '/?.lua'
    package.path = package.path .. ';' .. nix_lua_path .. '/?/init.lua'
    package.cpath = package.cpath .. ';' .. nix_lua_cpath .. '/?.so'
  end
end

setup_nix_lua_paths()
