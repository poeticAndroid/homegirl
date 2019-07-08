function _init(args)
  snd = audio.load(args[1])
  if snd == nil then
    print("Couldn't play file " .. args[1])
    return sys.exit(1)
  end
  audio.play(0, snd)
  audio.play(3, snd)
  print("Playing " .. args[1] .. " at " .. audio.channelfreq(0) .. "Hz")
end

function _step()
  if audio.channelfreq(0) == 0 then
    sys.exit(0)
  end
end
