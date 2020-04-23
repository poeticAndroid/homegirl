function _init(args)
  if #args < 2 then
    print("Usage: mount <drive name> <location>")
    return sys.exit(1)
  end
  if not fs.mount(args[1], args[2]) then
    print("Could not mount '" .. args[1] .. "' drive")
  end
end
