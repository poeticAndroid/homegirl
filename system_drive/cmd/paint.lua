local Screen, Menu, FileRequester = require("screen"), require("menu"), require("filerequester")
local scrn, anim, frame, filename, saved
local canvasvp, toolbarvp, palettevp, sidebarvp
local updateagain, icons, wpaper, menu
local tools = {"move", "brush", "picker", "select", "fill", "line", "circle", "box"}
local tool, fgcolor, bgcolor

function _init(args)
  scrn = Screen:new("Loading..", 10, 2)
  gfx.fgcolor(0)
  gfx.bar(0, 0, 2, 2)
  gfx.fgcolor(1)
  gfx.bar(0, 0, 1, 1)
  gfx.bar(1, 1, 1, 1)
  wpaper = image.new(2, 2, 1)
  image.copy(wpaper, 0, 0, 0, 0, 2, 2)
  icons = image.load(_DIR .. "paint.gif")
  local sw, sh = view.size(scrn.rootvp)
  local hk = sh / 240
  menu = {
    {
      label = "File",
      menu = {
        {label = "Load..", action = reqload, hotkey = "l"},
        {label = "Save", hotkey = "s"},
        {label = "Save as.."},
        {label = "Quit", action = quit, hotkey = "q"}
      }
    },
    {
      label = "Screen",
      menu = {
        {
          label = "Size",
          onopen = updatesizemenu,
          menu = {
            {label = " 80x" .. math.floor(60 * hk), _mode = 0, action = reqmode, hotkey = "0"},
            {label = "160x" .. math.floor(60 * hk), _mode = 1, action = reqmode},
            {label = "320x" .. math.floor(60 * hk), _mode = 2, action = reqmode},
            {label = "640x" .. math.floor(60 * hk), _mode = 3, action = reqmode},
            {label = " 80x" .. math.floor(120 * hk), _mode = 4, action = reqmode},
            {label = "160x" .. math.floor(120 * hk), _mode = 5, action = reqmode, hotkey = "1"},
            {label = "320x" .. math.floor(120 * hk), _mode = 6, action = reqmode},
            {label = "640x" .. math.floor(120 * hk), _mode = 7, action = reqmode},
            {label = " 80x" .. math.floor(240 * hk), _mode = 8, action = reqmode},
            {label = "160x" .. math.floor(240 * hk), _mode = 9, action = reqmode},
            {label = "320x" .. math.floor(240 * hk), _mode = 10, action = reqmode, hotkey = "2"},
            {label = "640x" .. math.floor(240 * hk), _mode = 11, action = reqmode},
            {label = " 80x" .. math.floor(480 * hk), _mode = 12, action = reqmode},
            {label = "160x" .. math.floor(480 * hk), _mode = 13, action = reqmode},
            {label = "320x" .. math.floor(480 * hk), _mode = 14, action = reqmode},
            {label = "640x" .. math.floor(480 * hk), _mode = 15, action = reqmode, hotkey = "3"}
          }
        },
        {
          label = "Colors",
          onopen = updatecolorsmenu,
          menu = {
            {label = "  2", _bpp = 1, action = reqbpp},
            {label = "  4", _bpp = 2, action = reqbpp},
            {label = "  8", _bpp = 3, action = reqbpp},
            {label = " 16", _bpp = 4, action = reqbpp},
            {label = " 32", _bpp = 5, action = reqbpp},
            {label = " 64", _bpp = 6, action = reqbpp},
            {label = "128", _bpp = 7, action = reqbpp},
            {label = "256", _bpp = 8, action = reqbpp}
          }
        }
      }
    }
  }
  menu = scrn:attachwindow("menu", Menu:new(menu))
  menu.onopen = function()
    return view.focused(canvasvp) == false and view.focused(palettevp) == false
  end

  filename = "user:"
  anim = {image.new(32, 32, 5)}
  frame = 1
  bgcolor = 0
  fgcolor = 1
  canvasvp = view.new(scrn.rootvp, 0, 0, 32, 32)
  makepointer()
  toolbarvp = view.new(scrn.rootvp, 0, 0, 10, #icons * 9 + 1)
  sidebarvp = view.new(scrn.rootvp, 0, 0, 1, 1)
  palettevp = view.new(scrn.rootvp, 0, 0, 1, 1)
  view.zindex(scrn.titlevp, -1)
  sys.stepinterval(-2)
  if args[1] then
    loadanim(args[1])
  else
    screenmode(10, 5)
  end
end

function _step(t)
  if updateagain then
    updateui()
  end
  stepui(t)
  scrn:step(t)
  autohideui()
end

function reqload()
  if scrn.children["req"] then
    return
  end
  local req = FileRequester:new("Load GIF..", {".gif"}, filename .. "/../")
  req.ondone = function(self, filename)
    if filename then
      loadanim(filename)
    end
  end
  scrn:attachwindow("req", req)
end
function loadanim(_filename)
  for i, img in ipairs(anim) do
    image.forget(img)
  end
  filename = _filename
  anim = image.load(filename)
  frame = 1
  local iw, ih = image.size(anim[frame])
  view.size(canvasvp, iw, ih)
  local mode, bpp = scrn:mode()
  screenmode(mode, minbpp(anim))
  saved = true
end

function quit()
  sys.exit()
end

function updatesizemenu(struct)
  local mode, bpp = scrn:mode()
  for i, item in ipairs(struct.menu) do
    item.checked = mode == item._mode
  end
end
function updatecolorsmenu(struct)
  local mode, bpp = scrn:mode()
  for i, item in ipairs(struct.menu) do
    item.checked = bpp == item._bpp
  end
end

function reqmode(struct)
  local mode, bpp = scrn:mode()
  screenmode(struct._mode, bpp)
end
function reqbpp(struct)
  local mode, bpp = scrn:mode()
  screenmode(mode, struct._bpp)
end

function screenmode(mode, bpp)
  scrn:mode(mode, bpp)
  local sw, sh = view.size(scrn.rootvp)
  view.position(scrn.mainvp, 0, 0)
  view.size(scrn.mainvp, sw, sh)
  local vw, vh = view.size(canvasvp)
  view.position(canvasvp, (sw - vw) / 2, (sh - vh) / 2)
  view.size(palettevp, sw, sh)
  view.size(sidebarvp, 24, sh)
  updateui()
  updateagain = true
end
function updateui()
  scrn:usepalette(anim[frame])
  scrn:autocolor()
  scrn:title(filename .. "[" .. frame .. "/" .. #anim .. "]" .. (saved and "" or " *"))

  local mode, bpp = scrn:mode()
  local sw, sh = view.size(scrn.rootvp)
  local x, y, s = 0, 0, 0

  if updateagain then
    view.active(scrn.mainvp)
    image.copymode(7)
    image.draw(wpaper, 0, 0, 0, 0, sw, sh)
  end

  view.active(toolbarvp)
  gfx.bgcolor(scrn.darkcolor)
  gfx.fgcolor(scrn.lightcolor)
  gfx.cls()
  image.copymode(7)
  x, y = 1, 1
  for i = 1, #icons do
    if tool == i then
      gfx.bar(x - 1, y - 1, 1, 10)
      image.draw(icons[i], x + 1, y, 0, 0, 8, 8)
    else
      image.draw(icons[i], x, y, 0, 0, 8, 8)
    end
    y = y + 9
  end

  view.active(propvp)
  gfx.bgcolor(scrn.darkcolor)
  gfx.cls()

  view.active(canvasvp)
  local iw, ih = image.size(anim[frame])
  image.draw(anim[frame], 0, 0, 0, 0, iw, ih)

  view.active(palettevp)
  image.copymode(7)
  x, y = view.size(palettevp)
  image.draw(wpaper, 0, 0, x, y, sw, sh)
  s = math.min(math.max(3, math.floor(sw / 32)), 10)
  x, y = 0, 1
  for i = 0, math.pow(2, bpp) - 1 do
    if x > sw - s then
      x = 0
      y = y + s
    end
    gfx.fgcolor(i)
    local d = (fgcolor == i and -1 or (bgcolor == i and 1 or 0))
    gfx.bar(x + d, y + d, s, s)
    x = x + s
  end
  view.size(palettevp, sw, y + s)

  local gm, gc = view.screenmode(scrn.rootvp)
  local lm, lc = view.screenmode(canvasvp)
  updateagain = (gm ~= lm) or (gc ~= lc)
end
function autohideui()
  view.active(scrn.rootvp)
  local mx, my, mb = input.mouse()
  if mb > 0 or menu.struct.vp or scrn.children["req"] then
    return
  end
  local sw, sh = view.size(scrn.rootvp)
  local vw, vh, foc
  local x, y, smy = 0, 0, my

  view.active(canvasvp)
  vw, vh = view.size(canvasvp)
  mx, my, mb = input.mouse()
  if mx >= 0 and my >= 0 and mx < vw and my < vh then
    foc = canvasvp
  end

  view.active(scrn.titlevp)
  vw, vh = view.size(scrn.titlevp)
  mx, my, mb = input.mouse()
  if my > vh then
    view.position(scrn.titlevp, 0, -vh)
  else
    view.position(scrn.titlevp, 0, 0)
    foc = scrn.mainvp
  end

  view.active(toolbarvp)
  vw, vh = view.size(toolbarvp)
  mx, my, mb = input.mouse()
  if vh < sh then
    y = (1 / 2) * (sh - vh)
  else
    y = (smy / sh) * (sh - vh)
  end
  if mx > vw then
    view.position(toolbarvp, -vw, y)
  else
    view.position(toolbarvp, 0, y)
    foc = toolbarvp
  end

  view.active(sidebarvp)
  vw, vh = view.size(sidebarvp)
  mx, my, mb = input.mouse()
  if mx < -1 then
    view.position(sidebarvp, sw, top)
  else
    view.position(sidebarvp, sw - vw, top)
    foc = sidebarvp
  end

  view.active(palettevp)
  vw, vh = view.size(palettevp)
  mx, my, mb = input.mouse()
  if my < -1 then
    view.position(palettevp, 0, sh)
  else
    view.position(palettevp, 0, sh - vh)
    foc = palettevp
  end
  if foc and view.focused(foc) == false then
    view.focused(foc, true)
  end
end

function stepui(t)
  local mx, my, mb
  view.active(palettevp)
  mx, my, mb = input.mouse()
  if mb == 1 then
    fgcolor = gfx.pixel(mx, my)
    view.active(canvasvp)
    gfx.fgcolor(fgcolor)
    updateui()
  end
  if mb == 2 then
    bgcolor = gfx.pixel(mx, my)
    view.active(canvasvp)
    gfx.bgcolor(bgcolor)
    updateui()
  end

  view.active(toolbarvp)
  mx, my, mb = input.mouse()
  if mb == 1 then
    tool = math.floor(my / 9) + 1
    updateui()
  end
end

function makepointer()
  gfx.fgcolor(1)
  gfx.line(0, 5, 10, 5)
  gfx.line(5, 0, 5, 10)
  gfx.fgcolor(0)
  gfx.plot(5, 5)
  gfx.fgcolor(2)
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
