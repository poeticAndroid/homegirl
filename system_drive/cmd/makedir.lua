function _init(args)
  if #args < 1 then
    print("Usage: makedir <path>")
    return sys.exit(1)
  end
  if not fs.mkdir(args[1]) then
    print("Could not make directory '" .. args[1] .. "'!")
  end
end
