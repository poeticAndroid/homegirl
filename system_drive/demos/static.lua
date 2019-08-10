Screen = require("sys:libs/screen")

function _init()
  sys.stepinterval(0)
  scrn = Screen:new("Static", 15, 5)
  scrn:colors(15, 0)
end

function _step(t)
  for y = 0, 360 do
    for x = 0, 640 do
      gfx.fgcolor(math.random(0, 255))
      gfx.plot(x, y)
    end
  end
  if input.hotkey() == "\x1b" then
    sys.exit(0)
  end
  scrn:step()
end
