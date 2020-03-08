local Screen, Menu, FileRequester = require("screen"), require("menu"), require("filerequester")
local scrn, anim, frame, filename, saved, history
local canvasvp, toolbarvp, palettevp, sidebarvp
local updateagain, icons, wpaper, menu
local tools = {"move", "brush", "picker", "select", "fill", "line", "circle", "box"}
local tool, fgcolor, bgcolor, brushsize
local brushmode, brushmasked, brushcolor, brush = 3, true, 1024, nil
local startx, starty
local clipx, clipy, clipw, cliph = 0, 0, 1, 1
local globalpal, fixedfps = true, true
local playing = false

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
        {label = "Save", action = save, hotkey = "s"},
        {label = "Save as..", action = reqsave},
        {label = "Quit", action = quit, hotkey = "q"}
      }
    },
    {
      label = "Brush",
      onopen = updatebrushmenu,
      menu = {
        {label = "Masked", _masked = true, action = reqbrushmode, hotkey = "m"},
        {
          label = "Bitwise",
          onopen = updatebrushmenu,
          menu = {
            {label = "Zero", _mode = 0, action = reqbrushmode},
            {label = "ConNonimpl", _mode = 1, action = reqbrushmode},
            {label = "And", _mode = 2, action = reqbrushmode},
            {label = "Source", _mode = 3, action = reqbrushmode, hotkey = "0"},
            {label = "MatNonimpl", _mode = 4, action = reqbrushmode},
            {label = "Xor", _mode = 5, action = reqbrushmode},
            {label = "Dest", _mode = 6, action = reqbrushmode},
            {label = "Or", _mode = 7, action = reqbrushmode},
            {label = "Not", _mode = 8, action = reqbrushmode}
          }
        },
        {
          label = "Index math",
          onopen = updatebrushmenu,
          menu = {
            {label = "Min", _mode = 9, action = reqbrushmode},
            {label = "Max", _mode = 10, action = reqbrushmode},
            {label = "Average", _mode = 11, action = reqbrushmode},
            {label = "Add", _mode = 12, action = reqbrushmode},
            {label = "Subtract", _mode = 13, action = reqbrushmode},
            {label = "Multiply", _mode = 14, action = reqbrushmode},
            {label = "Divide", _mode = 15, action = reqbrushmode}
          }
        },
        {
          label = "Color",
          onopen = updatebrushmenu,
          menu = {
            {label = "Background", _mode = 16, action = reqbrushmode},
            {label = "Foreground", _mode = 17, action = reqbrushmode, hotkey = "9"},
            {label = "Src bg", _mode = 18, action = reqbrushmode},
            {label = "Source", _mode = 20, action = reqbrushmode},
            {label = "Darker", _mode = 21, action = reqbrushmode},
            {label = "Lighter", _mode = 22, action = reqbrushmode},
            {label = "Average", _mode = 23, action = reqbrushmode},
            {label = "Add", _mode = 24, action = reqbrushmode},
            {label = "Subtract", _mode = 25, action = reqbrushmode},
            {label = "Multiply", _mode = 26, action = reqbrushmode},
            {label = "Hue", _mode = 28, action = reqbrushmode},
            {label = "Saturation", _mode = 29, action = reqbrushmode},
            {label = "Lightness", _mode = 30, action = reqbrushmode},
            {label = "Grayness", _mode = 31, action = reqbrushmode}
          }
        }
      }
    },
    {
      label = "Anim",
      onopen = updateanimmenu,
      menu = {
        {label = "Global palette", action = toggleglobalpal},
        {label = "Fixed framerate", action = togglefixedfps},
        {label = "Insert frame", action = insertframe, hotkey = "n"},
        {label = "Remove frame", action = removeframe, hotkey = "e"},
        {label = "Clear frame", action = clearframe, hotkey = "k"}
      }
    },
    {
      label = "Screen",
      menu = {
        {
          label = "Size",
          onopen = updatesizemenu,
          menu = {
            {label = " 80x" .. math.floor(60 * hk), _mode = 0, action = reqmode, hotkey = "1"},
            {label = "160x" .. math.floor(60 * hk), _mode = 1, action = reqmode},
            {label = "320x" .. math.floor(60 * hk), _mode = 2, action = reqmode},
            {label = "640x" .. math.floor(60 * hk), _mode = 3, action = reqmode},
            {label = " 80x" .. math.floor(120 * hk), _mode = 4, action = reqmode},
            {label = "160x" .. math.floor(120 * hk), _mode = 5, action = reqmode, hotkey = "2"},
            {label = "320x" .. math.floor(120 * hk), _mode = 6, action = reqmode},
            {label = "640x" .. math.floor(120 * hk), _mode = 7, action = reqmode},
            {label = " 80x" .. math.floor(240 * hk), _mode = 8, action = reqmode},
            {label = "160x" .. math.floor(240 * hk), _mode = 9, action = reqmode},
            {label = "320x" .. math.floor(240 * hk), _mode = 10, action = reqmode, hotkey = "3"},
            {label = "640x" .. math.floor(240 * hk), _mode = 11, action = reqmode},
            {label = " 80x" .. math.floor(480 * hk), _mode = 12, action = reqmode},
            {label = "160x" .. math.floor(480 * hk), _mode = 13, action = reqmode},
            {label = "320x" .. math.floor(480 * hk), _mode = 14, action = reqmode},
            {label = "640x" .. math.floor(480 * hk), _mode = 15, action = reqmode, hotkey = "4"}
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
  anim = {}
  history = {}
  frame = 1
  tool = 1
  bgcolor = 0
  fgcolor = 1
  brushsize = 1
  brush = image.new(brushsize, brushsize, 8)
  canvasvp = view.new(scrn.rootvp, 0, 0, 32, 32)
  makepointer()
  toolbarvp = view.new(scrn.rootvp, 0, 0, 10, #icons * 9 + 1)
  sidebarvp = view.new(scrn.rootvp, 0, 0, 1, 1)
  palettevp = view.new(scrn.rootvp, 0, 0, 1, 1)
  view.zindex(scrn.titlevp, -1)
  sys.stepinterval(-2)
  loadanim(args[1] or "user:new.gif")
end

function _step(t)
  if playing then
    frame = frame + 1
    if frame > #anim then
      frame = 1
    end
    if not globalpal then
      scrn:usepalette(anim[frame])
    end
    scrn:title(
      filename ..
        "[" ..
          frame ..
            "/" .. #anim .. " " .. image.duration(anim[fixedfps and 1 or frame]) .. "ms]" .. (saved and "" or " *")
    )
    view.active(canvasvp)
    local iw, ih = image.size(anim[frame])
    image.draw(anim[frame], 0, 0, 0, 0, iw, ih)
    sys.stepinterval(image.duration(anim[fixedfps and 1 or frame]))
    if #anim <= 1 then
      view.active(scrn.rootvp)
      input.text("5")
    end
  end
  if updateagain then
    updateui()
  end
  view.active(scrn.rootvp)
  local key = input.text()
  input.text("")
  if key == "1" then
    frame = 1
  elseif key == "2" then
    if frame > 1 then
      frame = frame - 1
    else
      frame = #anim
    end
  elseif key == "3" then
    if frame < #anim then
      frame = frame + 1
    else
      frame = 1
    end
  elseif key == "4" then
    frame = #anim
  elseif key == "5" then
    playing = not playing
    sys.stepinterval(-2)
  elseif key == "6" then
    local f = fixedfps and 1 or frame
    if image.duration(anim[f]) >= 10 then
      makeuniq(f)
      image.duration(anim[f], math.abs(image.duration(anim[f]) - 10))
    end
  elseif key == "7" then
    local f = fixedfps and 1 or frame
    makeuniq(f)
    image.duration(anim[f], image.duration(anim[f]) + 10)
  elseif key == "-" then
    if brushsize > 1 then
      brushsize = brushsize - 1
    end
    brushcolor = 1024
  elseif key == "+" then
    brushsize = brushsize + 1
    brushcolor = 1024
  elseif key == " " then
    tool = 1
    while tools[tool] ~= "move" do
      tool = tool + 1
    end
  elseif key == "b" then
    tool = 1
    while tools[tool] ~= "brush" do
      tool = tool + 1
    end
  elseif key == "x" then
    tool = 1
    while tools[tool] ~= "box" do
      tool = tool + 1
    end
  else
    if key ~= "" then
      for i, v in ipairs(tools) do
        if string.sub(v, 1, #key) == key then
          tool = i
        end
      end
    end
  end
  if key ~= "" then
    updateui()
  end
  key = input.hotkey()
  if key == "z" then
    undo()
  end
  stepui(t)
  stepcanvas(t)
  scrn:step(t)
  autohideui()
  if view.focused(canvasvp) == true or view.focused(palettevp) == true then
    menu:close()
  end
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
  playing = false
  sys.stepinterval(-2)
  for i, img in ipairs(anim) do
    pcall(image.forget, img)
  end
  while #history > 0 do
    for i, v in ipairs(history[1]) do
      pcall(image.forget, v)
    end
    table.remove(history, 1)
  end
  filename = _filename
  anim = image.load(filename) or {defaultimage()}
  frame = 1
  local iw, ih = image.size(anim[frame])
  view.size(canvasvp, iw, ih)
  local mode, bpp = scrn:mode()
  screenmode(mode, minbpp(anim))
  globalpal = hasglobalpal(anim)
  fixedfps = hasfixedfps(anim)
  commit()
  saved = true
end

function reqsave()
  if scrn.children["req"] then
    return
  end
  local req = FileRequester:new("Save GIF..", {".gif"}, filename .. "/../")
  req.ondone = function(self, filename)
    if filename then
      saveanim(filename)
    end
  end
  scrn:attachwindow("req", req)
end
function save()
  saveanim(filename)
end
function saveanim(_filename)
  filename = _filename or filename
  if globalpal and not hasglobalpal(anim) then
    for i, v in ipairs(anim) do
      makeuniq(i)
    end
  end
  if fixedfps then
    local ms = image.duration(anim[1])
    for i, v in ipairs(anim) do
      if image.duration(v) ~= ms then
        makeuniq(i)
        image.duration(anim[i], ms)
      end
    end
  end
  image.save(filename, anim)
  saved = true
  updateagain = true
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
function updatebrushmenu(struct)
  for i, item in ipairs(struct.menu) do
    item.checked = brushmode == item._mode
    if item._masked then
      item.checked = brushmasked
    end
  end
end
function updateanimmenu(struct)
  struct.menu[1].checked = globalpal
  struct.menu[2].checked = fixedfps
end

function reqmode(struct)
  local mode, bpp = scrn:mode()
  screenmode(struct._mode, bpp)
end
function reqbpp(struct)
  local mode, bpp = scrn:mode()
  screenmode(mode, struct._bpp)
end
function reqbrushmode(struct)
  if struct._masked then
    brushmasked = not brushmasked
  else
    brushmode = struct._mode
  end
end
function toggleglobalpal(struct)
  globalpal = not globalpal
  updateui()
end
function togglefixedfps(struct)
  fixedfps = not fixedfps
  updateui()
end

function insertframe()
  table.insert(anim, frame, makeuniq(frame))
  commit()
  frame = frame + 1
  updateui()
end
function removeframe()
  if #anim > 1 then
    table.remove(anim, frame)
    commit()
  end
  if frame > #anim then
    frame = #anim
  end
  updateui()
end
function clearframe()
  view.active(canvasvp)
  makeuniq(frame)
  gfx.cls()
  copycanvas(anim[frame])
  commit()
  updateui()
end

function screenmode(mode, bpp)
  scrn:mode(mode, bpp)
  local sw, sh = view.size(scrn.rootvp)
  view.position(scrn.mainvp, 0, 0)
  view.size(scrn.mainvp, sw, sh)
  view.position(scrn.titlevp, 0, 0)
  view.position(toolbarvp, 0, 16)
  local vw, vh = view.size(canvasvp)
  view.position(canvasvp, (sw - vw) / 2, (sh - vh) / 2)
  view.position(palettevp, 0, 0)
  view.size(palettevp, sw, sh)
  view.position(sidebarvp, 0, 0)
  view.size(sidebarvp, 24, sh)
  updateui()
  updateagain = true
end
function updateui()
  scrn:usepalette(anim[globalpal and 1 or frame])
  scrn:autocolor()
  scrn:title(
    filename ..
      "[" ..
        frame .. "/" .. #anim .. " " .. image.duration(anim[fixedfps and 1 or frame]) .. "ms]" .. (saved and "" or " *")
  )

  local mode, bpp = scrn:mode()
  local sw, sh = view.size(scrn.rootvp)
  local x, y, s = 0, 0, 0

  if updateagain then
    view.active(scrn.mainvp)
    image.copymode(20)
    image.draw(wpaper, 0, 0, 0, 0, sw, sh)
  end

  view.active(toolbarvp)
  gfx.bgcolor(scrn.darkcolor)
  gfx.fgcolor(scrn.lightcolor)
  gfx.cls()
  image.copymode(20)
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

  view.active(sidebarvp)
  gfx.bgcolor(scrn.darkcolor)
  gfx.cls()
  local f = globalpal and 1 or frame
  local r, g, b = image.palette(anim[f], fgcolor)
  x, y = view.size(sidebarvp)
  gfx.fgcolor(gfx.nearestcolor(15, 0, 0))
  gfx.bar(0, (1 - r / 15) * y, 8, y)
  gfx.fgcolor(gfx.nearestcolor(0, 15, 0))
  gfx.bar(8, (1 - g / 15) * y, 8, y)
  gfx.fgcolor(gfx.nearestcolor(0, 0, 15))
  gfx.bar(16, (1 - b / 15) * y, 8, y)

  view.active(canvasvp)
  local iw, ih = image.size(anim[frame])
  view.size(canvasvp, iw, ih)
  image.copymode(3)
  image.draw(anim[frame], 0, 0, 0, 0, iw, ih)
  bgcolor = gfx.bgcolor(image.bgcolor(anim[globalpal and 1 or frame]))

  view.active(palettevp)
  image.copymode(20)
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
  x, y = view.size(palettevp, sw, y + s)
  view.size(sidebarvp, 24, sh - y - 11)

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
  local focs = 0
  local x, y, smy = 0, 0, my

  view.active(canvasvp)
  vw, vh = view.size(canvasvp)
  local cl, ct = view.position(canvasvp)
  local cr, cb = sw - vw - cl, sh - vh - ct
  mx, my, mb = input.mouse()
  if mx >= 0 and my >= 0 and mx < vw and my < vh then
    foc = canvasvp
  end

  view.active(scrn.titlevp)
  vw, vh = view.size(scrn.titlevp)
  mx, my, mb = input.mouse()
  if my > vh then
    if ct < vh then
      view.position(scrn.titlevp, 0, -vh)
    end
  else
    view.position(scrn.titlevp, 0, 0)
    foc = scrn.titlevp
    focs = focs + 1
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
    if cl < vw then
      view.position(toolbarvp, -vw, y)
    end
  else
    view.position(toolbarvp, 0, y)
    foc = toolbarvp
    focs = focs + 1
  end

  view.active(sidebarvp)
  vw, vh = view.size(sidebarvp)
  mx, my, mb = input.mouse()
  if mx < -1 then
    if cr < vw then
      view.position(sidebarvp, sw, 11)
    end
  else
    view.position(sidebarvp, sw - vw, 11)
    foc = sidebarvp
    focs = focs + 1
  end

  view.active(palettevp)
  vw, vh = view.size(palettevp)
  mx, my, mb = input.mouse()
  if my < -1 then
    if cb < vh then
      view.position(palettevp, 0, sh)
    end
  else
    view.position(palettevp, 0, sh - vh)
    foc = palettevp
    focs = focs + 1
  end

  if focs == 1 then
    view.zindex(foc, -1)
  end
  if foc == scrn.titlevp then
    foc = scrn.mainvp
  end
  if foc and view.focused(foc) == false then
    view.focused(foc, true)
    updateui()
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
    image.bgcolor(anim[globalpal and 1 or frame], bgcolor)
    updateui()
  end

  view.active(toolbarvp)
  mx, my, mb = input.mouse()
  if mb == 1 then
    tool = math.floor(my / 9) + 1
    startx, starty = nil, nil
    updateui()
  end

  view.active(sidebarvp)
  local vw, vh = view.size(sidebarvp)
  mx, my, mb = input.mouse()
  if mb == 1 then
    local f = globalpal and 1 or frame
    local r, g, b = image.palette(makeuniq(f), fgcolor)
    local ch = math.floor(mx / (vw / 3))
    if ch == 0 then
      image.palette(anim[f], fgcolor, (1 - my / vh) * 15, g, b)
    elseif ch == 1 then
      image.palette(anim[f], fgcolor, r, (1 - my / vh) * 15, b)
    elseif ch == 2 then
      image.palette(anim[f], fgcolor, r, g, (1 - my / vh) * 15)
    end
    updateui()
  end
end
function stepcanvas(t)
  view.active(canvasvp)
  local mx, my, mb = input.mouse()
  if tools[tool] == "move" then
    local vx, vy = view.position(canvasvp)
    local vw, vh = view.size(canvasvp)
    local iw, ih = image.size(anim[frame])
    if mb == 1 then
      if startx then
        view.position(canvasvp, vx + mx - startx, vy + my - starty)
      else
        startx, starty = mx, my
      end
    elseif mb == 2 then
      if not startx then
        clipx, clipy = (mx - vw / 2) / vw, (my - vh / 2) / vh
        if math.abs(clipx) > math.abs(clipy) then
          clipy = 0
        else
          clipx = 0
        end
        startx, starty = 0, 0
      end
      if clipx > 0 then
        view.size(canvasvp, mx, vh)
      elseif clipy > 0 then
        view.size(canvasvp, vw, my)
      elseif clipx < 0 then
        startx = startx - mx
        view.size(canvasvp, vw - mx, vh)
        view.position(canvasvp, vx + mx, vy)
      elseif clipy < 0 then
        starty = starty - my
        view.size(canvasvp, vw, vh - my)
        view.position(canvasvp, vx, vy + my)
      end
      gfx.cls()
      image.draw(anim[frame], startx, starty, 0, 0, iw, ih)
    else
      if clipx and startx then
        resizeanim(startx, starty, vw - iw - startx, vh - ih - starty)
        commit()
      end
      clipx, clipy = nil, nil
      startx, starty = nil, nil
    end
  elseif tools[tool] == "brush" then
    local iw, ih = image.size(anim[frame])
    if mb > 0 then
      if mb > 1 then
        updatebrush(gfx.fgcolor(bgcolor))
      else
        updatebrush(gfx.fgcolor(fgcolor))
      end
      if startx then
        paintline(startx, starty, mx, my, 1)
      else
        makeuniq()
        image.copymode(brushmode, brushmasked)
        paintat(mx, my)
      end
      startx, starty = mx, my
    else
      image.copymode(3)
      if startx then
        copycanvas(anim[frame])
        commit()
      end
      image.draw(anim[frame], 0, 0, 0, 0, iw, ih)
      image.copymode(brushmode, brushmasked)
      updatebrush(gfx.fgcolor(fgcolor))
      paintat(mx, my)
      startx, starty = nil, nil
    end
  elseif tools[tool] == "picker" then
    if mb == 1 then
      fgcolor = gfx.pixel(mx, my)
      gfx.fgcolor(fgcolor)
      updateui()
    end
    if mb == 2 then
      bgcolor = gfx.pixel(mx, my)
      gfx.bgcolor(bgcolor)
      image.bgcolor(anim[frame], bgcolor)
      updateui()
    end
  elseif tools[tool] == "select" then
    local iw, ih = image.size(anim[frame])
    if mb > 0 then
      if startx then
        image.copymode(3)
        image.draw(anim[frame], 0, 0, 0, 0, iw, ih)
        gfx.fgcolor(scrn.darkcolor)
        gfx.line(startx - 1, starty - 1, mx, starty - 1)
        gfx.line(startx - 1, starty - 1, startx - 1, my)
        gfx.line(startx - 1, my, mx, my)
        gfx.line(mx, starty - 1, mx, my)
        gfx.fgcolor(scrn.lightcolor)
        gfx.line(startx - 2, starty - 2, mx + 1, starty - 2)
        gfx.line(startx - 2, starty - 2, startx - 2, my + 1)
        gfx.line(startx - 2, my + 1, mx + 1, my + 1)
        gfx.line(mx + 1, starty - 2, mx + 1, my + 1)
      else
        makeuniq()
        startx, starty = mx, my
      end
    else
      image.copymode(3)
      image.draw(anim[frame], 0, 0, 0, 0, iw, ih)
      if startx then
        clipx, clipy = math.max(0, math.min(mx, startx)), math.max(0, math.min(my, starty))
        clipw, cliph = math.min(iw, math.abs(mx - startx)), math.min(ih, math.abs(my - starty))
        image.forget(brush)
        brush = image.new(clipw, cliph, 8)
        image.copy(brush, clipx, clipy, 0, 0, clipw, cliph)
        image.copypalette(brush)
        image.bgcolor(brush, bgcolor)
        brushcolor = clipw == 0 or cliph == 0
      end
      image.copymode(brushmode, brushmasked)
      updatebrush(gfx.fgcolor(fgcolor))
      paintat(mx, my)
      startx, starty = nil, nil
    end
  elseif tools[tool] == "fill" then
    if mb > 0 then
      if mb > 1 then
        gfx.fgcolor(bgcolor)
      else
        gfx.fgcolor(fgcolor)
      end
      makeuniq()
      local target = gfx.pixel(mx, my)
      local pool = {{mx, my}}
      if gfx.fgcolor() == target then
        table.remove(pool)
      end
      local iw, ih = image.size(anim[frame])
      while #pool > 0 do
        local p = table.remove(pool)
        if gfx.pixel(p[1], p[2]) == target and p[1] >= 0 and p[2] >= 0 and p[1] < iw and p[2] < ih then
          gfx.plot(p[1], p[2])
          table.insert(pool, {p[1], p[2] - 1})
          table.insert(pool, {p[1], p[2] + 1})
          table.insert(pool, {p[1] - 1, p[2]})
          table.insert(pool, {p[1] + 1, p[2]})
        end
      end
      startx, starty = mx, my
    else
      if startx then
        copycanvas(anim[frame])
        commit()
      end
      startx, starty = nil, nil
    end
  elseif tools[tool] == "line" then
    local iw, ih = image.size(anim[frame])
    if mb > 0 then
      if mb > 1 then
        updatebrush(gfx.fgcolor(bgcolor))
      else
        updatebrush(gfx.fgcolor(fgcolor))
      end
      if startx then
        image.copymode(3)
        image.draw(anim[frame], 0, 0, 0, 0, iw, ih)
        image.copymode(brushmode, brushmasked)
        paintline(startx, starty, mx, my)
      else
        makeuniq()
        image.copymode(brushmode, brushmasked)
        paintat(mx, my)
        startx, starty = mx, my
      end
    else
      image.copymode(3)
      if startx then
        copycanvas(anim[frame])
        commit()
      end
      image.draw(anim[frame], 0, 0, 0, 0, iw, ih)
      image.copymode(brushmode, brushmasked)
      updatebrush(gfx.fgcolor(fgcolor))
      paintat(mx, my)
      startx, starty = nil, nil
    end
  elseif tools[tool] == "circle" then
    local iw, ih = image.size(anim[frame])
    if mb > 0 then
      if mb > 1 then
        updatebrush(gfx.fgcolor(bgcolor))
      else
        updatebrush(gfx.fgcolor(fgcolor))
      end
      if startx then
        image.copymode(3)
        image.draw(anim[frame], 0, 0, 0, 0, iw, ih)
        image.copymode(brushmode, brushmasked)
        paintcircle(startx, starty, mx - startx, my - starty)
      else
        makeuniq()
        image.copymode(brushmode, brushmasked)
        paintat(mx, my)
        startx, starty = mx, my
      end
    else
      image.copymode(3)
      if startx then
        copycanvas(anim[frame])
        commit()
      end
      image.draw(anim[frame], 0, 0, 0, 0, iw, ih)
      image.copymode(brushmode, brushmasked)
      updatebrush(gfx.fgcolor(fgcolor))
      paintat(mx, my)
      startx, starty = nil, nil
    end
  elseif tools[tool] == "box" then
    local iw, ih = image.size(anim[frame])
    if mb > 0 then
      if mb > 1 then
        updatebrush(gfx.fgcolor(bgcolor))
      else
        updatebrush(gfx.fgcolor(fgcolor))
      end
      if startx then
        image.copymode(3)
        image.draw(anim[frame], 0, 0, 0, 0, iw, ih)
        image.copymode(brushmode, brushmasked)
        paintline(startx, starty, mx, starty, 1)
        paintline(mx, starty, mx, my, 1)
        paintline(mx, my, startx, my, 1)
        paintline(startx, my, startx, starty, 1)
      else
        makeuniq()
        image.copymode(brushmode, brushmasked)
        paintat(mx, my)
        startx, starty = mx, my
      end
    else
      image.copymode(3)
      if startx then
        copycanvas(anim[frame])
        commit()
      end
      image.draw(anim[frame], 0, 0, 0, 0, iw, ih)
      image.copymode(brushmode, brushmasked)
      updatebrush(gfx.fgcolor(fgcolor))
      paintat(mx, my)
      startx, starty = nil, nil
    end
  end
end

function commit()
  local commit = {}
  for i, v in ipairs(anim) do
    table.insert(commit, v)
  end
  table.insert(history, commit)
  while #history > 32 do
    for i, v in ipairs(history[1]) do
      local uniq = true
      for j, w in ipairs(history[2]) do
        if v == w then
          uniq = false
        end
      end
      if uniq then
        image.forget(v)
      end
    end
    table.remove(history, 1)
  end
  saved = false
end
function undo()
  local commit = table.remove(history)
  local same = #commit == #anim
  while same do
    for i, v in ipairs(anim) do
      if anim[i] ~= commit[i] then
        same = false
        frame = i
      end
    end
    if same and #history > 0 then
      commit = table.remove(history)
      same = #commit == #anim
    else
      same = false
    end
  end
  table.insert(history, commit)
  for i, v in ipairs(anim) do
    local uniq = true
    for j, w in ipairs(commit) do
      if v == w then
        uniq = false
      end
    end
    if uniq then
      image.forget(v)
    end
  end
  anim = {}
  for j, w in ipairs(commit) do
    table.insert(anim, w)
  end
  saved = false
  if frame > #anim then
    frame = #anim
  end
  updateui()
end
function copycanvas(img)
  view.active(canvasvp)
  local w, h = view.size(canvasvp)
  local mode, bpp = scrn:mode()

  local newframe = img or image.new(w, h, bpp)
  image.copypalette(newframe)
  image.copy(newframe, 0, 0, 0, 0, w, h)
  image.bgcolor(newframe, bgcolor)
  image.duration(newframe, image.duration(anim[fixedfps and 1 or frame]))
  return newframe
end
function makeuniq(framenum)
  framenum = framenum or frame
  local oldframe = frame
  local commit = history[#history]
  local uniq = true
  for i, v in ipairs(commit) do
    if anim[framenum] == v then
      uniq = false
    end
  end
  if not uniq then
    frame = framenum
    updateui()
    anim[frame] = copycanvas()
    if frame ~= oldframe then
      frame = oldframe
      updateui()
    end
    saved = false
  end
  return anim[framenum]
end

function resizeanim(l, t, r, b)
  view.active(canvasvp)
  local iw, ih = image.size(anim[1])
  view.size(canvasvp, l + iw + r, t + ih + b)
  for i, v in ipairs(anim) do
    if not globalpal then
      scrn:usepalette(v)
      bgcolor = image.bgcolor(v)
    end
    gfx.cls()
    image.draw(v, l, t, 0, 0, iw, ih)
    anim[i] = copycanvas()
    if not fixedfps then
      image.duration(anim[i], image.duration(v))
    end
  end
  updateui()
end

function updatebrush(fgcolor)
  if brushcolor then
    local bw, bh = image.size(brush)
    if bw ~= brushsize or bh ~= brushsize then
      image.forget(brush)
      brush = image.new(brushsize, brushsize, 8)
      brushcolor = 1024
    end
    if brushcolor ~= fgcolor then
      for y = 0, brushsize do
        for x = 0, brushsize do
          image.pixel(brush, x, y, fgcolor)
        end
      end
      brushcolor = fgcolor
      image.copypalette(brush)
      image.bgcolor(brush, fgcolor == bgcolor and fgcolor + 1 or bgcolor)
    end
  end
end

function paintat(x, y)
  local bw, bh = image.size(brush)
  image.draw(brush, x - math.floor(bw / 2), y - math.floor(bh / 2), 0, 0, bw, bh)
end
function paintline(x1, y1, x2, y2, s)
  local l = math.max(math.abs(x1 - x2), math.abs(y1 - y2))
  if l == 0 then
    if s then
      return
    end
    return paintat(x1, y1)
  end
  for i = (s or 0), l do
    paintat(x1 + .5 + (i / l) * (x2 - x1), y1 + .5 + (i / l) * (y2 - y1))
  end
end
function paintcircle(cx, cy, rx, ry)
  if rx == 0 and ry == 0 then
    paintat(cx, cy)
  else
    div = rx == ry and 4 or 2
    step = 8 / (2 * math.pi * math.abs(math.min(rx, ry)))
    for a = 0, math.pi / div, step do
      x1 = math.round(rx * math.sin(a))
      y1 = math.round(ry * math.cos(a))
      x2 = math.round(rx * math.sin(a + step))
      y2 = math.round(ry * math.cos(a + step))
      paintline(cx + x1, cy - y1, cx + x2, cy - y2)
      paintline(cx + x1, cy + y1, cx + x2, cy + y2)
      paintline(cx - x1, cy - y1, cx - x2, cy - y2)
      paintline(cx - x1, cy + y1, cx - x2, cy + y2)
      if div == 4 then
        paintline(cx + y1, cy - x1, cx + y2, cy - x2)
        paintline(cx + y1, cy + x1, cx + y2, cy + x2)
        paintline(cx - y1, cy - x1, cx - y2, cy - x2)
        paintline(cx - y1, cy + x1, cx - y2, cy + x2)
      end
    end
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

function hasglobalpal(anim)
  local bpp = image.colordepth(anim[1])
  local colors = math.pow(2, bpp)
  for i = 2, #anim do
    for c = 0, colors - 1 do
      local r1, g1, b1 = image.palette(anim[1], c)
      local r2, g2, b2 = image.palette(anim[i], c)
      if r1 ~= r2 or g1 ~= g2 or b1 ~= b2 then
        return false
      end
    end
  end
  return true
end

function hasfixedfps(anim)
  local firstint = image.duration(anim[1])
  for i = 2, #anim do
    if firstint ~= image.duration(anim[i]) then
      return false
    end
  end
  return true
end

function defaultimage()
  local img = image.new(160, 90, 6)
  image.pixel(img, 0, 0, 255)
  return img
end

function math.round(x)
  return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end
