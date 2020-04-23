function _init(args)
  if #args < 1 then
    print("Usage: reimage <source> <destination>")
    return sys.exit(1)
  end
  snd = audio.load(args[1])
  if snd == nil then
    print("Couldn't load file " .. args[1])
    return sys.exit(1)
  end
  audio.save(args[#args], snd)
end
