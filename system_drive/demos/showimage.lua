Screen = require("sys:libs/screen")

x = -100
y = -170

function _init()
  sys.stepinterval(1000 / 60)
  scrn = Screen:new("showimage.lua", 10, 5)
  pointer = image.load("./images/pointer.gif", 1)[1]

  img = image.load("./images/Pharao.gif", 1)[1]
  width, height = image.size(img)
  scrn:usepalette(img)
  image.copymode(1)
end

function _step()
  local mx, my, mbtn = input.mouse()
  image.draw(img, 160 - (width / 2), 90 - height / 2, 0, 0, width, height)
  gfx.bar(x, y, 100, 100)
  x = x + 1
  y = y + 1
  image.draw(pointer, mx, my, 0, 0, 16, 16)
  if y > 320 then
    x = -100
    y = -170
  end
  if input.hotkey() == "\x1b" then
    sys.exit(0)
  end
  scrn:step()
end
