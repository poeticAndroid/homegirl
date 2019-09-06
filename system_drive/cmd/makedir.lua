function _init(args)
  if not fs.mkdir(args[1]) then
    print("Could not make directory '" .. args[1] .. "'!")
  end
end
