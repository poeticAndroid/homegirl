function _init(args)
  if #args < 1 then
    print("Usage: more <path>")
    return sys.exit(1)
  end
  txt = fs.read(args[1])
  if txt == nil then
    print("Couldn't type file " .. args[1])
    return sys.exit(1)
  end
  pos = 0
  print("(press enter to scroll down)")
end

function _step()
  local inp = sys.read()
  if inp ~= "\n" then
    return
  end
  local char = ""
  while char ~= "\n" and pos < #txt do
    sys.write(char)
    pos = pos + 1
    char = string.sub(txt, pos, pos)
  end
  if pos >= #txt then
    sys.exit()
  end
end
