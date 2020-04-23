function _init(args)
  if #args < 1 then
    print("Usage: delete <path>")
    return sys.exit(1)
  end
  if not fs.delete(args[1]) then
    print("Could not delete '" .. args[1] .. "'!")
    return sys.exit(1)
  end
end
