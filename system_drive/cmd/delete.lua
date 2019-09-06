function _init(args)
  if not fs.delete(args[1]) then
    print("Could not delete '" .. args[1] .. "'!")
  end
end
