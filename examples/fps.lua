sec = 0
frames = 0

function _step(t)
  s = math.floor(t / 1000)
  frames = frames + 1
  if sec < s then
    meh.print(frames .. " fps")
    sec = s
    frames = 0
  end
end
