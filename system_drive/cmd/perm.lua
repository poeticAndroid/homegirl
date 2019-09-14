local SYMS = {
  "mpm",
  "mld",
  "mrd",
  "uod",
  "mms",
  "mop",
  "rod",
  "wod",
  "rev",
  "wev"
}
local PERM = {
  mpm = 1,
  mld = 2,
  mrd = 4,
  uod = 8,
  mms = 16,
  mop = 32,
  rod = 256,
  wod = 512,
  rev = 1024,
  wev = 2048
}
local PERMDESC = {
  mpm = "Manage permissions",
  mld = "Mount local drives",
  mrd = "Mount remote drives",
  uod = "Unmount other drives",
  mms = "Manage main screen",
  mop = "Manage other programs",
  rod = "Read other drives",
  wod = "Write to other drives",
  rev = "Read environment variables",
  wev = "Set environment variables"
}

function _init(args)
  if #args < 1 then
    print("Usage: perm <drive>")
    return sys.exit(1)
  end
  local perms = sys.permissions(args[1])
  for i = 2, #args do
    if tonumber(args[i]) then
      perms = args[i]
    elseif PERM[string.lower(args[i])] then
      perms = perms ~ PERM[string.lower(args[i])]
    end
  end
  if #args > 1 then
    perms = sys.permissions(args[1], perms)
  end
  if perms then
    print("Permissions for programs on " .. string.upper(args[1]) .. " drive\n")
    for i, sym in pairs(SYMS) do
      print(sym .. " = " .. ((perms & PERM[string.lower(sym)] > 0) and "true  " or "false ") .. "-- " .. PERMDESC[sym])
    end
    print("\nPermission sum: " .. perms)
  else
    print("Could not access permissions of " .. string.upper(args[1]) .. " drive")
  end
end
