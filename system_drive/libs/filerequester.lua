local Widget, path = require("widget"), require("path")

local FileRequester = Widget:extend()
do
  function FileRequester:constructor(title, suffixes, default)
    self.title = title or "Select a file"
    self.suffixes = suffixes or {""}
    self.filename = path.resolve(fs.cd(), default)
    if fs.isdir(self.filename) then
      self.filename = path.trailslash(self.filename)
    end
    self.list = {}
    table.insert(self.suffixes, "/")
  end

  function FileRequester:attachto(parent, vp, screen)
    Widget.attachto(self, parent, vp, screen)
    local sw, sh = view.size(self.screen)
    self:position(sw / 4, sh / 4)
    self:size(sw / 2, sh / 2)
    input.text(self.filename)
    input.clearhistory()
    self.filename = self.filename .. "/."
    self:step(42)
  end

  function FileRequester:step(time)
    local prevvp = view.active()
    view.active(self.container)

    local list = self.list
    local delta = #(input.text()) - #(self.filename)
    self.filename = input.text()
    if self.filename == path.trailslash(self.filename) then
      self.dirname = self.filename
      self.basename = ""
    else
      self.dirname = path.dirname(self.filename)
      self.basename = path.basename(self.filename)
    end
    if #(self.dirname) < 2 then
      self.dirname = ""
    end
    if string.find(self.basename, "\t") then
      self.basename = self.list[1] or ""
      self.filename = input.text(self.dirname .. self.basename)
      if self.filename == path.trailslash(self.filename) then
        self.dirname = self.filename
        self.basename = ""
      end
    end
    if delta < 0 or (delta > 0 and self.filename == path.trailslash(self.filename)) then
      list = fs.list(self.dirname) or {}
    end
    self.list = {}
    if #(self.dirname) < 2 then
      list = fs.drives()
    end
    for i, name in ipairs(list) do
      if #(self.dirname) < 2 then
        name = name .. ":"
      end
      local good = #(self.dirname) < 2
      for i, suff in ipairs(self.suffixes) do
        if suff == "" or string.lower(string.sub(name, -(#suff))) == suff then
          good = true
        end
      end
      if string.lower(string.sub(name, 1, #(self.basename))) ~= string.lower(self.basename) then
        good = false
      end
      if good then
        table.insert(self.list, name)
      end
    end

    self:redraw(time)
    view.active(prevvp)
    if input.hotkey() == "\x1b" then
      self.parent:destroychild(self)
      self:ondone()
    end
    if string.find(self.filename, "\n") then
      self.parent:destroychild(self)
      self:ondone(string.gsub(self.filename, "\n", ""))
    end
  end

  function FileRequester:redraw()
    local prevvp = view.active()
    local cw, ch = view.size(self.container)
    local x, y = 0, 0
    view.active(self.container)
    gfx.bgcolor(self.darkcolor)
    gfx.fgcolor(self.lightcolor)
    local tw, th = text.draw(self.title, self.font, 0, 0)
    gfx.cls()
    gfx.bar(0, 0, cw, th + 2)
    gfx.bar(0, 0, 1, ch)
    gfx.bar(0, ch - 1, cw, 1)
    gfx.bar(cw - 1, 0, 1, ch)
    gfx.fgcolor(self.darkcolor)
    text.draw(self.title, self.font, 1, 1)
    local chwidth = tw / #(self.title)
    gfx.fgcolor(self.lightcolor)

    local cpos, csel = input.cursor()
    x, y = 2, th + 3
    tw, th = text.draw(self:_letterwrap(self.filename, math.floor((cw - 4) / chwidth)), self.font, x, y)
    tw, th =
      text.draw(
      self:_letterwrap(string.sub(self.filename, 1, cpos) .. "\x7f", math.floor((cw - 4) / chwidth)),
      self.font,
      x,
      y
    )
    gfx.fgcolor(self.darkcolor)
    tw, th =
      text.draw(
      self:_letterwrap(string.sub(self.filename, 1, cpos + 1), math.floor((cw - 4) / chwidth)),
      self.font,
      x,
      y
    )
    gfx.fgcolor(self.lightcolor)
    tw, th =
      text.draw(self:_letterwrap(string.sub(self.filename, 1, cpos), math.floor((cw - 4) / chwidth)), self.font, x, y)

    y = y + th + 1
    gfx.bar(x, y, cw - x * 2, 1)
    y = y + 2
    local top, maxw = y, 0
    for i, name in ipairs(self.list) do
      tw, th = text.draw(name, self.font, x, y)
      y = y + th
      if tw > maxw then
        maxw = tw
      end
      if y + th >= ch then
        x, y = x + maxw + chwidth / 2, top
        maxw = 0
      end
    end

    view.active(prevvp)
  end

  function FileRequester:_letterwrap(txt, width)
    local out, pos = "", 0
    for i = 1, #txt do
      local ch = string.sub(txt, i, i)
      if ch == "\n" then
        pos = -1
      end
      if pos >= width then
        out = out .. "\n"
        pos = 0
      end
      out = out .. ch
      pos = pos + 1
    end
    return out
  end
end
return FileRequester
