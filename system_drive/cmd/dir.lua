function _init(args)
  list = fs.list(args[1])
  table.sort(list)
  for i, entry in pairs(list) do
    print(entry)
  end
end
