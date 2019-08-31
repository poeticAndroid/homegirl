function _init(args)
  if not fs.mount(args[1], args[2]) then
    print("Could not mount '" .. args[1] .. "' drive")
  end
end
