local sheet, sheetw, sheeth, font, x, dot, bg, maxw, wsum, dest, bpp, bw

function _init(args)
  dest = args[2]
  sheet = image.load(args[1])[1]
  sheetw, sheeth = image.size(sheet)
  dest = string.gsub(dest, "%.gif", "." .. (sheeth - 1) .. "c.gif")
  font = {}
  x = 0
  maxw = 0
  wsum = 0
  view.newscreen(15, 8)
  image.usepalette(sheet)
  image.draw(sheet, 0, 4, 0, 0, sheetw, sheeth)
  image.draw(sheet, 0, 0, 0, 0, sheetw, sheeth)
  dot = gfx.pixel(0, 0)
  bg = gfx.pixel(1, 0)
  gfx.fgcolor(dot)
  gfx.bgcolor(bg)
  sys.stepinterval(16)

  local maxc, c, uni = 0, 0, {}
  for y = 1, (sheeth - 1) do
    for x = 1, 79 do
      c = gfx.pixel(x, y)
      if c > maxc then
        maxc = c
      end
      if not contains(uni, c) then
        table.insert(uni, c)
      end
    end
  end
  bpp = 0
  while maxc > 0 do
    maxc = math.floor(maxc / 2)
    bpp = bpp + 1
  end
  if #uni <= 2 then
    gobw(8)
    bw = true
    bpp = 1
    dest = string.gsub(dest, "c%.gif", ".gif")
  end
  -- fs.delete(dest .. ".txt", args[1] .. "\t" .. bpp .. "\n")
  -- bpp = 4
end

function _step()
  if x >= sheetw then
    return sys.exit()
  end
  gfx.cls()
  gfx.bar(0, 0, 640, 1)
  image.draw(sheet, -x, 0, 0, 0, sheetw, sheeth)
  if gfx.pixel(0, 0) == dot then
    local w = 1
    while gfx.pixel(w + 1, 0) ~= dot do
      w = w + 1
      if w > 80 then
        return sys.exit()
      end
    end
    if w > maxw then
      maxw = w
    end
    wsum = wsum + w
    if bw then
      gobw(w)
    end
    local char = image.new(w, sheeth - 1, bpp)
    image.copy(char, 1, 1, 0, 0, w, sheeth - 1)
    image.copypalette(char)
    image.duration(char, w * 10)
    table.insert(font, char)
  end
  x = x + 1
end

function _shutdown(code)
  if code == 0 then
    gfx.cls()
    if bw then
      bg = 0
      gfx.fgcolor(1)
    end
    local char = image.new(maxw, sheeth - 1, bpp)
    image.copy(char, 1, 1, 0, 0, maxw, sheeth - 1)
    image.copypalette(char)
    image.duration(char, (wsum / #font) * 10)
    table.insert(font, 1, char)

    char = image.new(maxw, sheeth - 1, bpp)
    image.copy(char, 1, 1, 0, 0, maxw, sheeth - 1)
    image.copypalette(char)
    image.duration(char, 0)

    while #font < 97 do
      table.insert(font, char)
    end

    for n = 34, 59 do
      if font[91] == char then
        font[n + 32] = font[n]
      end
    end

    gfx.line(1, 1, maxw, 1)
    gfx.line(1, 1, maxw, sheeth - 1)
    gfx.line(1, 1, 1, sheeth - 1)
    gfx.line(1, sheeth - 1, maxw, sheeth - 1)
    gfx.line(maxw, 1, maxw, sheeth - 1)
    gfx.line(maxw, 1, 1, sheeth - 1)
    char = image.new(maxw, sheeth - 1, bpp)
    image.copy(char, 1, 1, 0, 0, maxw, sheeth - 1)
    image.copypalette(char)
    image.duration(char, maxw * 10)
    font[97] = char

    gfx.bar(0, 0, maxw, sheeth)
    char = image.new(maxw, sheeth - 1, bpp)
    image.copy(char, 1, 1, 0, 0, maxw, sheeth - 1)
    image.copypalette(char)
    image.duration(char, maxw * 10)
    font[96] = char

    image.save(dest, font)
  end
end

function contains(tab, srch)
  for i, item in pairs(tab) do
    if item == srch then
      return true
    end
  end
  return false
end

function gobw(w)
  local c
  gfx.bgcolor(0)
  gfx.palette(0, 0, 0, 0)
  gfx.palette(1, 15, 15, 15)
  for y = 1, sheeth do
    for x = 0, w do
      c = gfx.pixel(x, y)
      if c == bg then
        gfx.pixel(x, y, 0)
      else
        gfx.pixel(x, y, 1)
      end
    end
  end
end
