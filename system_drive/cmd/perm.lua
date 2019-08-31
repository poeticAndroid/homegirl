function _init(args)
  local perms = sys.permissions(args[1], args[2])
  if perms then
    print("Permissions: " .. perms)
  else
    print("Could not access permissions of '" .. args[1] .. "' drive")
  end
end
