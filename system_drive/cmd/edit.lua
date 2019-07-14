screendrag = require("sys:libs/screendrag")
filename = nil
lasttxt = ""
scrn = view.newscreen(11, 2)
font = text.loadfont("sys:fonts/Victoria.8b.gif")

function _init(args)
  gfx.palette(0, 0, 0, 5)
  gfx.palette(1, 15, 15, 15)
  gfx.palette(2, 0, 0, 2)
  gfx.palette(3, 0, 10, 15)
  gfx.bgcolor(0)
  gfx.fgcolor(1)
  if #args > 0 then
    filename = args[1]
    input.text(fs.read(filename))
    input.clearhistory()
  else
    print("filename missing!")
    sys.exit(1)
  end
  input.cursor(0)
end

function _step(t)
  local txt = input.text()
  local change = txt ~= lasttxt
  local deltalen = #txt - #lasttxt
  local pos, sel = input.cursor()
  local lines = getlines(txt)
  line, col = txtpos(txt, pos)
  local top = 86 - 8 * line
  if top > 0 then
    top = 0
  end
  if deltalen > 0 then
    if string.sub(txt, pos, pos) == "\n" then
      input.selected(getindent(lines[line - 1]))
      txt = input.text()
    end
    if string.sub(txt, pos - 1, pos) == "\n\t" or string.sub(txt, pos - 2, pos) == "  \t" then
      pos = pos - 1
      sel = 1
      input.cursor(pos, sel)
      input.selected("  ")
      txt = input.text()
    end
    pos, sel = input.cursor()
  end
  if input.hotkey() == "s" then
    fs.write(filename, input.text())
    print("saved " .. filename)
  end
  lasttxt = txt

  gfx.cls()
  gfx.fgcolor(1)
  text.draw(txt, font, 0, top)
  gfx.fgcolor(3)
  text.draw(string.sub(txt, 0, pos) .. "\x7f", font, 0, top)
  text.draw(string.sub(txt, 0, pos + sel), font, 0, top)
  if sel == 0 then
    gfx.fgcolor(2)
  else
    gfx.fgcolor(1)
  end
  text.draw(string.sub(txt, 0, pos + 1), font, 0, top)
  gfx.fgcolor(1)
  text.draw(string.sub(txt, 0, pos), font, 0, top)
  screendrag.step(scrn)
end

function _shutdown()
  if input.text() ~= fs.read(filename) then
    print("exiting without saving!")
  end
end

function txtpos(txt, pos)
  local line = 1
  local col = 0
  for i = 0, pos do
    col = col + 1
    if string.sub(txt, i, i) == "\n" then
      line = line + 1
      col = 0
    end
  end
  return line, col
end

function getlines(txt)
  local lines = {}
  local line = ""
  for i = 1, #txt do
    if string.sub(txt, i, i) == "\n" then
      table.insert(lines, line)
      line = ""
    else
      line = line .. string.sub(txt, i, i)
    end
  end
  table.insert(lines, line)
  return lines
end

function getindent(line)
  local indent = ""
  for i = 1, #line do
    if string.sub(line, i, i) == " " then
      indent = indent .. string.sub(line, i, i)
    else
      break
    end
  end
  return indent
end