Screen, Menu, FileRequester = require("screen"), require("menu"), require("filerequester")

filename = nil
lasttxt = ""
statustxt = ""
statusto = 0

function _init(args)
  scrn = Screen:new("Edit", 11, 2)
  menu =
    Menu:new(
    {
      {
        label = "File",
        menu = {
          {label = "Load..", hotkey = "l", action = reqload},
          {
            label = "Save",
            hotkey = "s",
            action = function(self)
              save(filename)
            end
          },
          {label = "Save as..", action = reqsave},
          {label = "Quit", action = quit, hotkey = "q"}
        }
      }
    }
  )
  scrn:attach("menu", menu)
  font = text.loadfont("Victoria.8b")
  scrn:palette(0, 0, 0, 0)
  scrn:palette(1, 13, 14, 15)
  scrn:palette(2, 0, 3, 8)
  scrn:palette(3, 0, 10, 15)
  gfx.bgcolor(0)
  gfx.fgcolor(1)
  load(args[1] or "user:")
  input.linesperpage(20)
end

function _step(t)
  local txt = input.text()
  local change = txt ~= lasttxt
  local deltalen = #txt - #lasttxt
  local pos, sel = input.cursor()
  local lines = getlines(txt)
  local gutter = ""
  local gutterw = 0
  line, col = txtpos(txt, pos)
  local top = 86 - 8 * line
  local left = 500 - 8 * col
  if top > 0 then
    top = 0
  end
  if left > 0 then
    left = 0
  end
  if deltalen > 0 then
    if string.sub(txt, pos - 1, pos) == "\n\t" or string.sub(txt, pos - 2, pos) == "  \t" then
      pos = pos - 1
      sel = 1
      input.cursor(pos, sel)
      input.selected("  ")
      txt = input.text()
    end
    pos, sel = input.cursor()
  end
  if change then
    if txt == savedtxt then
      scrn:title(filename)
    else
      scrn:title(filename .. " *")
    end
  end
  lasttxt = txt

  gutterw = string.len("" .. #lines)
  for i = 1, #lines do
    gutter = gutter .. string.format("%0" .. gutterw .. "d", i) .. "\n"
  end
  gfx.cls()
  gutterw = text.draw(gutter, font, 0, top) + 8
  gfx.fgcolor(1)
  text.draw(txt, font, gutterw + left, top)
  gfx.fgcolor(3)
  text.draw(string.sub(txt, 0, pos) .. "\x7f", font, gutterw + left, top)
  text.draw(string.sub(txt, 0, pos + sel), font, gutterw + left, top)
  if sel == 0 then
    gfx.fgcolor(2)
  else
    gfx.fgcolor(1)
  end
  text.draw(string.sub(txt, 0, pos + 1), font, gutterw + left, top)
  gfx.fgcolor(1)
  text.draw(string.sub(txt, 0, pos), font, gutterw + left, top)
  gfx.fgcolor(0)
  gfx.bar(0, 0, gutterw, 1024)
  gfx.fgcolor(3)
  text.draw(gutter, font, 0, top)
  scrn:step()
end

function _shutdown()
  if input.text() ~= savedtxt then
    print("exiting without saving!")
  end
end

function quit()
  sys.exit()
end

function reqload()
  if scrn.children["req"] then
    return
  end
  local req = FileRequester:new("Load..", {""}, filename .. "/../")
  req.ondone = function(self, filename)
    if filename then
      load(filename)
    end
  end
  scrn:attachwindow("req", req)
end
function load(_filename)
  filename = _filename
  savedtxt = fs.read(filename)
  lasttxt = savedtxt or ""
  view.active(scrn.mainvp)
  input.text(lasttxt)
  input.clearhistory()
  input.cursor(0)
  scrn:title(filename)
end
function reqsave()
  if scrn.children["req"] then
    return
  end
  local req = FileRequester:new("Save as..", {""}, filename)
  req.ondone = function(self, filename)
    if filename then
      save(filename)
    end
  end
  scrn:attachwindow("req", req)
end
function save(_filename)
  filename = _filename
  if fs.write(filename, input.text()) then
    setstatus("saved!")
    savedtxt = input.text()
  else
    setstatus("could not save!")
  end
  lasttxt = savedtxt or ""
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

function setstatus(txt)
  scrn:title(filename .. " - " .. txt)
end
