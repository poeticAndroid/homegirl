function _init(args)
  if #args < 1 then
    print("Usage: rename <source> <destination>")
    return sys.exit(1)
  end
  if not fs.rename(args[1], args[2]) then
    print("Could not rename '" .. args[1] .. "'!")
  end
end
