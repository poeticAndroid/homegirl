function _init(args)
  if #args >= 2 then
    sys.env(args[1], args[2])
  end
  if #args >= 1 then
    if sys.env(args[1]) then
      print(args[1] .. " = " .. sys.env(args[1]))
    else
      print(args[1] .. " has no value!")
    end
  else
    list = sys.listenv()
    table.sort(list)
    for i, entry in pairs(list) do
      print(entry .. " = " .. sys.env(entry))
    end
  end
end
