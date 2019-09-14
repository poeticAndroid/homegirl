function _init(args)
  if #args < 1 then
    print("Usage: type <path>")
    return sys.exit(1)
  end
  txt = fs.read(args[1])
  if txt == nil then
    print("Couldn't type file " .. args[1])
    return sys.exit(1)
  end
  print(txt)
end
