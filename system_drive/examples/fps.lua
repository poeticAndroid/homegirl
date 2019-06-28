sec = 0
frames = 0

function _step(t)
  s = math.floor(t / 1000)
  frames = frames + 1
  if sec < s then
    print(frames .. " fps")
    sec = s
    frames = 0
  end
  if t > 60000 then
    sys.exit(0)
  end
end
