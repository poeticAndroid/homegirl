function _init(args)
  sys.stepinterval(0)
  snd = audio.new()
  filename = args[1]
  print("(press enter to stoprecording)")
end

function _step()
  audio.record(snd)
  local inp = sys.read()
  if inp == "\n" then
    if audio.save(filename, snd) then
      print("Recording saved to " .. filename)
    else
      print("Could not save recording to " .. filename)
    end
    sys.exit()
  end
end
