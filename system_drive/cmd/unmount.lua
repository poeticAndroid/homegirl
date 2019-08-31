function _init(args)
  if not fs.unmount(args[1], args[2] == "force") then
    print("Could not unmount '" .. args[1] .. "' drive")
  end
end
