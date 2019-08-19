function _init()
  list = fs.drives()
  table.sort(list)
  print("Available drives:\n")
  for i, entry in pairs(list) do
    print("  " .. entry .. ":")
  end
  print("")
end
