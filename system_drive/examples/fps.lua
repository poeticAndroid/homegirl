sec = 0
frames = 0
to = 0
sys.stepinterval(0)

function _step(t)
  s = math.floor(t / 1000)
  frames = frames + 1
  if sec < s then
    print(frames .. " fps")
    sec = s
    frames = 0
  end
  if to == 0 then
    to = s + 10
  end
  if s > to then
    sys.exit(0)
  end
end

function _shutdown(code)
  print("fps done! " .. tostring(code))
end
