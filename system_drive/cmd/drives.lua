function _init()
  list = fs.drives()
  table.sort(list)
  for i, entry in pairs(list) do
    print(entry .. ":")
  end
end
