local Screen, Menu, FileRequester = require("screen"), require("menu"), require("filerequester")
local scrn, menu, mode, depth, anim, frame, tool, icons
local toolvp, propvp, palettevp, canvasvp, wpaper
local cx, cy, modechecked, bppchecked
local updateonnextstep

function _init(args)
  anim = {image.new(32, 32, 5)}
  frame = 1
  local iw, ih = image.size(anim[frame])
  depth = image.colordepth(anim[frame])
  mode = 10
  scrn = Screen:new(args[1], mode, depth)
  gfx.fgcolor(0)
  gfx.bar(0, 0, 2, 2)
  gfx.fgcolor(1)
  gfx.bar(0, 0, 1, 1)
  gfx.bar(1, 1, 1, 1)
  wpaper = image.new(2, 2, 1)
  image.copy(wpaper, 0, 0, 0, 0, 2, 2)
  icons = image.load(_DIR .. "paint.gif")
  local sw, top = view.size(scrn.titlevp)
  local sw, sh = view.size(scrn.rootvp)
  canvasvp = view.new(scrn.rootvp, 16, 16, iw, ih)
  makepointer()
  toolvp = view.new(scrn.rootvp, 0, top, 10, #icons * 9 + 1)
  propvp = view.new(scrn.rootvp, 0, 0, 40, sh)
  palettevp = view.new(scrn.rootvp, 0, 0, sw, sh)
  view.zindex(scrn.titlevp, -1)
  local hk = sh / 240
  menu =
    Menu:new(
    {
      {
        label = "File",
        menu = {
          {label = "Load...", hotkey = "l", action = reqload},
          {label = "Save", hotkey = "s"},
          {label = "Save as..."}
        }
      },
      {
        label = "Screen",
        menu = {
          {
            label = "Size",
            menu = {
              {label = " 80x" .. math.floor(60 * hk), _mode = 0, action = checkmode, hotkey = "0"},
              {label = "160x" .. math.floor(60 * hk), _mode = 1, action = checkmode},
              {label = "320x" .. math.floor(60 * hk), _mode = 2, action = checkmode},
              {label = "640x" .. math.floor(60 * hk), _mode = 3, action = checkmode},
              {label = " 80x" .. math.floor(120 * hk), _mode = 4, action = checkmode},
              {label = "160x" .. math.floor(120 * hk), _mode = 5, action = checkmode, hotkey = "1"},
              {label = "320x" .. math.floor(120 * hk), _mode = 6, action = checkmode},
              {label = "640x" .. math.floor(120 * hk), _mode = 7, action = checkmode},
              {label = " 80x" .. math.floor(240 * hk), _mode = 8, action = checkmode},
              {label = "160x" .. math.floor(240 * hk), _mode = 9, action = checkmode},
              {label = "320x" .. math.floor(240 * hk), _mode = 10, action = checkmode, hotkey = "2"},
              {label = "640x" .. math.floor(240 * hk), _mode = 11, action = checkmode},
              {label = " 80x" .. math.floor(480 * hk), _mode = 12, action = checkmode},
              {label = "160x" .. math.floor(480 * hk), _mode = 13, action = checkmode},
              {label = "320x" .. math.floor(480 * hk), _mode = 14, action = checkmode},
              {label = "640x" .. math.floor(480 * hk), _mode = 15, action = checkmode, hotkey = "3"}
            }
          },
          {
            label = "Colors",
            menu = {
              {label = "  2"},
              {label = "  4"},
              {label = "  8"},
              {label = " 16"},
              {label = " 32"},
              {label = " 64"},
              {label = "128"},
              {label = "256"}
            }
          }
        }
      }
    }
  )
  menu:attachto(nil, scrn.rootvp, scrn.rootvp)
  sys.stepinterval(-2)
  if args[1] then
    loadanim(args[1])
  end
  gotoframe(1)
end

function _step(t)
  if updateonnextstep then
    updateui()
  end
  autohideui()
  view.active(scrn.rootvp)
  local mx, my, mb = input.mouse()
  if mb == 1 then
    view.position(canvasvp, mx - cx, my - cy)
  else
    cx = mx
    cy = my
  end

  if input.hotkey() == "u" then
    updateui()
  end
  if input.hotkey() == "\x1b" then
    sys.exit(0)
  end
  menu:step(t)
  scrn:step(t)
end

function reqload()
  local req = scrn:attachwindow("req", FileRequester:new())
end
function loadanim(filename)
  anim = image.load(filename)
  frame = 1
  local iw, ih = image.size(anim[frame])
  view.size(canvasvp, iw, ih)
  changemode(mode, image.colordepth(anim[frame]))
  view.active(canvasvp)
  changemode(mode, minbpp(anim))
end

function gotoframe(_frame)
  frame = _frame
  scrn:usepalette(anim[frame])
  scrn:autocolor()
  view.active(scrn.rootvp)
  menu.lightcolor = gfx.nearestcolor(15, 15, 15)
  menu.darkcolor = gfx.nearestcolor(0, 0, 0)
  menu.fgcolor = menu.darkcolor
  menu.bgcolor = menu.lightcolor
  menu.fgtextcolor = menu.lightcolor
  menu.bgtextcolor = menu.darkcolor
  updateui()
end

function checkmode(menuitem)
  if modechecked then
    modechecked.checked = false
  end
  changemode(menuitem._mode, depth)
  modechecked = menuitem
  modechecked.checked = true
end

function changemode(_mode, _depth)
  mode = _mode
  depth = _depth
  scrn:mode(mode, depth)
  gotoframe(frame)
end

function autohideui()
  local sw, top = view.size(scrn.titlevp)
  local sw, sh = view.size(scrn.rootvp)
  local mx, my, mb = input.mouse()
  local vw, vh

  view.active(toolvp)
  mx, my, mb = input.mouse()
  if mx < 18 then
    view.position(toolvp, 0, top)
  else
    view.position(toolvp, -17, top)
  end

  view.active(propvp)
  mx, my, mb = input.mouse()
  if mx >= 0 then
    view.position(propvp, sw - 40, top)
  else
    view.position(propvp, sw - 1, top)
  end

  view.active(palettevp)
  vw, vh = view.size(palettevp)
  mx, my, mb = input.mouse()
  if my >= 0 then
    view.position(palettevp, 0, sh - vh)
  else
    view.position(palettevp, 0, sh - 1)
  end
end

function updateui()
  sys.lookbusy()
  local sw, top = view.size(scrn.titlevp)
  local sw, sh = view.size(scrn.mainvp)
  local x, y, s = 0, 0, 0

  view.active(scrn.mainvp)
  image.copymode(7)
  image.draw(wpaper, 0, 0, 0, 0, sw, sh)

  view.active(toolvp)
  gfx.bgcolor(gfx.nearestcolor(0, 0, 0))
  gfx.cls()
  image.copymode(7)
  x, y = 1, 1
  for i = 1, #icons do
    image.draw(icons[i], x, y, 0, 0, 8, 8)
    y = y + 9
  end

  view.active(palettevp)
  gfx.bgcolor(gfx.nearestcolor(0, 0, 0))
  gfx.cls()
  image.copymode(7)
  x, y = 1, 1
  for i = 1, #icons do
    image.draw(icons[i], x, y, 0, 0, 8, 8)
    x = x + 10
  end
  x, y = 0, 10
  image.draw(wpaper, x, y, 0, 0, sw, sh)
  s = math.min(10, math.floor(sw / 32))
  for i = 0, math.pow(2, depth) - 1 do
    if x > sw - s then
      x = 0
      y = y + s
    end
    gfx.fgcolor(i)
    gfx.bar(x, y, s, s)
    x = x + s
  end
  view.size(palettevp, sw, y + s)

  view.active(propvp)
  gfx.bgcolor(gfx.nearestcolor(0, 0, 0))
  gfx.cls()

  view.active(canvasvp)
  local iw, ih = image.size(anim[frame])
  image.draw(anim[frame], 0, 0, 0, 0, iw, ih)
  local gm, gc = view.screenmode(scrn.rootvp)
  local lm, lc = view.screenmode(canvasvp)
  updateonnextstep = gm ~= lm or gc ~= lc
end

function makepointer()
  gfx.fgcolor(1)
  gfx.line(0, 5, 10, 5)
  gfx.line(5, 0, 5, 10)
  gfx.fgcolor(0)
  gfx.plot(5, 5)
  gfx.fgcolor(3)
  for i = 2, 20, 2 do
    gfx.plot(5 - i, 5)
    gfx.plot(5 + i, 5)
    gfx.plot(5, 5 - i)
    gfx.plot(5, 5 + i)
  end
  local pimg = image.new(11, 11, 2)
  image.copy(pimg, 0, 0, 0, 0, 11, 11)
  image.pointer(pimg, 5, 5)
end

function minbpp(anim)
  local colors, c, bpp = 0, 0, 0
  local w, h = image.size(anim[1])
  for i = 1, #anim do
    for y = 1, h do
      for x = 1, w do
        c = image.pixel(anim[i], x - 1, y - 1)
        if c > colors then
          colors = c
        end
      end
    end
  end
  colors = colors + 1
  while math.pow(2, bpp) < colors do
    bpp = bpp + 1
  end
  return bpp
end
