function _init(args)
  txt = fs.read(args[1])
  if txt == nil then
    print("Couldn't type file " .. args[1])
    return sys.exit(1)
  end
  print(txt)
end
