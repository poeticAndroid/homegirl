Screen = require("sys:libs/screen")

x = 0
y = 0
dx = 1
dy = 0
c = 0

function _init()
  sys.stepinterval(1000 / 60)
  scrn = Screen:new("Sun", 10, 4)
  scrn:colors(7, 0)
end

function _step()
  mx, my = input.mouse()
  y = y - 1
  local c = 0
  while x + y ~= 0 do
    x = x + dx
    y = y + dy
    c = c + 1
    gfx.fgcolor(c % 16)
    gfx.line(mx, my, x, y)
    if x > 319 then
      x = x - 1
      dx = 0
      dy = 1
    end
    if y > 179 then
      y = y - 1
      dx = -1
      dy = 0
    end
    if x < 0 then
      x = x + 1
      dx = 0
      dy = -1
    end
    if y < 0 then
      y = y + 1
      dx = 1
      dy = 0
    end
  end
  _cycle()
  if input.hotkey() == "\x1b" then
    sys.exit(0)
  end
  scrn:step()
end

function _cycle()
  c = c + 1
  for i = 0, 15 do
    scrn:palette(i, i + c, i + c, i + c)
  end
end
