Screen = require(_DRIVE .. "libs/screen")

x = -100
y = -170

function _init()
  sys.stepinterval(1000 / 60)
  scrn = Screen:new("Swing Tut", 10, 5)
  pointer = image.load("./images/pointer.gif", 1)[1]

  img = image.load("./images/Pharao.gif", 1)[1]
  width, height = image.size(img)
  scrn:usepalette(img)
  image.copymode(1)
end

function _step(t)
  local mx, my, mbtn = input.mouse()
  sx = 2 * math.sin(t / 1000)
  sy = 2 * math.sin(t / 1100)
  image.draw(img, 160 - (width * sx / 2), 90 - height * sy / 2, 0, 0, width * sx, height * sy, width, height)
  image.draw(pointer, mx, my, 0, 0, 16, 16)
  if input.hotkey() == "\x1b" then
    sys.exit(0)
  end
  scrn:step()
end
