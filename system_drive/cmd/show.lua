Screen = require("sys:libs/screen")

function _init(args)
  mode = 0
  anim = image.loadanimation(args[1])
  if anim == nil then
    print("Couldn't show file " .. args[1])
    return sys.exit(1)
  end
  scrn = Screen:new(args[1], mode, 8)
  view.visible(scrn.mainvp, false)
  view.active(scrn.rootvp)
  width, height = image.size(anim[1])
  print(args[1] .. ": " .. width .. " x " .. height .. " pixels")
  scrnw, scrnh = scrn:size()
  while width > scrnw do
    mode = mode + 5
    scrnw = scrnw * 2
    scrnh = scrnh * 2
  end
  if mode > 15 then
    mode = 15
  end
  if height > scrnh then
    mode = mode + 16
  end
  zoom(0)
  f = 0
  _lastbtn = 255
end

function _step(t)
  local mx, my, mbtn = input.mouse()
  local btn = input.gamepad()
  gfx.cls()
  f = f + 1
  if f > #anim then
    f = 1
  end
  if mbtn == 1 then
    x = mx + rx
    y = my + ry
  else
    rx = x - mx
    ry = y - my
    view.visible(scrn.titlevp, my <= 10)
  end
  if btn & 1 > 0 then
    x = x - 1
  end
  if btn & 2 > 0 then
    x = x + 1
  end
  if btn & 4 > 0 then
    y = y + 1
  end
  if btn & 8 > 0 then
    y = y - 1
  end
  if _lastbtn == 0 and btn & 16 > 0 then -- A
    zoom(-32)
  end
  if _lastbtn == 0 and btn & 32 > 0 then -- B
    zoom(16)
  end
  if _lastbtn == 0 and btn & 64 > 0 then -- X
    zoom(1)
  end
  if _lastbtn == 0 and btn & 128 > 0 then -- Y
    zoom(4)
  end
  _lastbtn = btn
  scrn:usepalette(anim[f])
  scrn:autocolor()
  image.draw(anim[f], x, y, 0, 0, width, height)
  if input.hotkey() == "\x1b" then
    sys.exit(0)
  end
  scrn:step()
  sys.stepinterval(image.duration(anim[f]))
end

function zoom(amount)
  mode = mode + amount
  if mode < 0 then
    mode = 0
  end
  while mode >= 32 do
    mode = mode - 32
  end
  scrn:mode(mode, 8)
  scrnw, scrnh = scrn:size()
  image.copymode(0)
  x = scrnw / 2 - width / 2
  y = scrnh / 2 - height / 2
end
