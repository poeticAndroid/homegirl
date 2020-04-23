function _init(args)
  if #args < 2 then
    print("Usage: unmount <drive> [force]")
    return sys.exit(1)
  end
  if not fs.unmount(args[1], args[2] == "force") then
    print("Could not unmount '" .. args[1] .. "' drive")
  end
end
