createscreen(3, 5)

sec = 0
frames = 0

function _step(t)
  for y = 0, 360 do
    for x = 0, 640 do
      setfgcolor(math.random(0, 255))
      plot(x, y)
    end
  end
  s = math.floor(t / 1000)
  frames = frames + 1
  if sec < s then
    print(frames .. " fps")
    sec = s
    frames = 0
  end
end

print("This is the program!")
