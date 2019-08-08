function _init(args)
  snd = audio.load(args[1])
  if snd == nil then
    print("Couldn't load file " .. args[1])
    return sys.exit(1)
  end
  audio.save(args[1], snd)
end
