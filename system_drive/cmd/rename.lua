function _init(args)
  if not fs.rename(args[1], args[2]) then
    print("Could not rename '" .. args[1] .. "'!")
  end
end
