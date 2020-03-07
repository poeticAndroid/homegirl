function _init(args)
  if not args[1] then
    return print("..delete what?")
  end
  if not fs.delete(args[1]) then
    print("Could not delete '" .. args[1] .. "'!")
  end
end
