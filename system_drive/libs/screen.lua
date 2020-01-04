local Widget = require("widget")

local defaultfont = text.loadfont("Victoria.8b")

local Screen = Widget:extend()
do
  function Screen:constructor(title, mode, colorbits)
    self.children = {}
    self._mode = mode
    self._colorbits = colorbits
    self.rootvp = view.newscreen(self._mode, self._colorbits)
    self.titlevp = view.new(self.rootvp, 0, 0, 8, 8)
    self.mainvp = view.new(self.rootvp, 0, 8, 8, 8)
    self:colors(1, 0)
    self:font(defaultfont)
    self:title(title)
  end

  function Screen:attach(name, child)
    if name then
      if self.children[name] then
        self:destroychild(name)
      end
      self.children[name] = child
    else
      table.insert(self.children, child)
    end
    child:attachto(self, self.mainvp, self.rootvp)
    return child
  end
  function Screen:attachwindow(name, child)
    if name then
      if self.children[name] then
        self:destroychild(name)
      end
      self.children[name] = child
    else
      table.insert(self.children, child)
    end
    child:attachto(self, self.rootvp, self.rootvp)
    return child
  end

  function Screen:font(font)
    if font then
      self._font = font
      local prevvp = view.active()
      view.active(self.titlevp)
      local sw, sh = view.size(self.rootvp)
      local tw, th = text.draw(self._title, self._font, 0, 0)
      view.size(self.titlevp, sw, th + 3)
      view.position(self.mainvp, 0, th + 3)
      view.size(self.mainvp, sw, sh - th - 3)
      self:title(self._title)
      view.active(prevvp)
    end
    return self._font
  end

  function Screen:title(title)
    if title then
      self._title = view.attribute(self.rootvp, "title", title)
      local prevvp = view.active()
      view.active(self.titlevp)
      gfx.bgcolor(self.lightcolor)
      gfx.fgcolor(self.darkcolor)
      local vw, vh = view.size(self.titlevp)
      local btnx = vw - vh * 2 - 2
      gfx.cls()
      local tw, th = text.draw(self._title, self._font, 1, 1)
      if tw >= btnx then
        gfx.cls()
        tw, th = text.draw(self._title, self._font, btnx - tw, 1)
      end
      gfx.bar(0, vh - 1, vw, 1)
      self:_drawbtn()
      view.active(prevvp)
    end
    return self._title
  end

  function Screen:step(time)
    local prevvp = view.active()
    view.active(self.titlevp)
    local vw, vh = view.size(self.titlevp)
    local btnx = vw - vh * 2
    local x, y, btn = input.mouse()
    if btn == 1 then
      if x < btnx then
        local top = self:top(self:top() + y - 5)
      else
        self:_drawbtn(true)
      end
    elseif view.focused(self.titlevp) then
      self:title(self._title)
      if self._lastmbtn == 1 and x >= btnx then
        view.zindex(self.rootvp, 0)
        view.focused(self.rootvp, false)
      else
        view.focused(self.mainvp, true)
      end
    end
    self._lastmbtn = btn
    view.active(self.rootvp)
    if input.hotkey() == "." then
      view.zindex(self.rootvp, 0)
      view.focused(self.rootvp, false)
    end
    for name, child in pairs(self.children) do
      child:step(time)
    end
    view.active(prevvp)
  end

  function Screen:palette(c, r, g, b)
    local prevvp = view.active()
    view.active(self.rootvp)
    local r, g, b = gfx.palette(c, r, g, b)
    view.active(prevvp)
    return r, g, b
  end

  function Screen:usepalette(img)
    local prevvp = view.active()
    view.active(self.rootvp)
    image.usepalette(img)
    view.active(prevvp)
  end

  function Screen:copypalette(img)
    local prevvp = view.active()
    view.active(self.rootvp)
    image.copypalette(img)
    view.active(prevvp)
  end

  function Screen:top(top)
    if top then
      view.position(self.rootvp, 0, top)
    end
    local left, top = view.position(self.rootvp)
    return top
  end

  function Screen:size()
    return view.size(self.mainvp)
  end

  function Screen:mode(mode, colorbits)
    if mode then
      self._mode = mode
      self._colorbits = colorbits
      view.screenmode(self.rootvp, self._mode, self._colorbits)
      self:font(self._font)
    end
    return self._mode, self._colorbits
  end

  function Screen:colors(bg, fg)
    self.darkcolor = fg
    self.lightcolor = bg
    self:title(self._title)
  end

  function Screen:autocolor()
    local prevvp = view.active()
    view.active(self.rootvp)
    local r, g, b, bg, fg, bgv, fgv, v
    local colors = math.pow(2, self._colorbits)
    bgv = -1
    fgv = 60
    for c = 0, colors - 1 do
      r, g, b = gfx.palette(c)
      v = r + g + b
      if v > bgv then
        bgv = v
        bg = c
      end
      if v < fgv then
        fgv = v
        fg = c
      end
    end
    self.darkcolor = fg
    self.lightcolor = bg
    self:title(self._title)
    view.active(prevvp)
  end

  function Screen:_drawbtn(pressed)
    local vw, vh = view.size(self.titlevp)
    local btnx = vw - vh * 2
    local s = vh * .55
    local bg, fg = self.lightcolor, self.darkcolor
    gfx.fgcolor(fg)
    gfx.bar(btnx - 2, 0, 2, vh)
    if pressed then
      gfx.bar(btnx, 0, vh * 3, vh)
      bg, fg = fg, bg
    end
    gfx.fgcolor(fg)
    gfx.bar(btnx + 2, 1, s * 2, s)
    gfx.fgcolor(bg)
    s = s - 2
    gfx.bar(btnx + 4, 2, s * 2, s)
    gfx.fgcolor(fg)
    s = s + 2
    gfx.bar(vw - s * 2 - 1, vh - s - 1, s * 2, s)
  end
end
return Screen
