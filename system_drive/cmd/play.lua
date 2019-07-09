function _init(args)
  snd = audio.load(args[1])
  if snd == nil then
    print("Couldn't play file " .. args[1])
    return sys.exit(1)
  end
  audio.play(0, snd)
  audio.play(3, snd)
  print("Playing " .. args[1] .. " at " .. audio.samplefreq(snd) .. "Hz")
  sys.stepinterval(128)
end

function _step()
  if audio.channelfreq(0) == 0 then
    sys.exit(0)
  end
end
