scrn = view.newscreen(11, 2)
scrnw, scrnh = view.size(scrn)
spare = image.new(scrnw, scrnh, 4)
font = text.loadfont("sys:fonts/Victoria.8b.gif")
fontsize = 8
fontw = 8
termline = ""
termbottom = fontsize
state = 1
task = nil
history = {}
histpos = #history

function _init()
  gfx.palette(0, 0, 5, 10)
  gfx.palette(1, 15, 15, 15)
  gfx.palette(2, 0, 0, 2)
  gfx.palette(3, 15, 8, 0)

  -- out("Homegirl Shell\n")
  out(sys.env("ENGINE") .. " version " .. sys.env("ENGINE_VERSION") .. "\n\n")
end

function _step()
  local inp = input.text()
  if string.find(inp, "\t") ~= nil then
    input.text(tabcomplete(inp, fs.list()))
  end
  if string.find(inp, "\n") ~= nil then
    submit(string.gsub(inp, "\n", ""))
  end
  if state == 0 then
    local btn = input.gamepad()
    if lastinp == inp and lastbtn == 0 and btn > 0 then
      if btn & 4 > 0 then
        histpos = histpos - 1
        if histpos < 1 then
          histpos = 1
        end
        input.text(history[histpos])
      end
      if btn & 8 > 0 then
        histpos = histpos + 1
        if histpos > #history then
          histpos = #history + 1
          input.text("")
        end
        input.text(history[histpos])
      end
    end
    lastbtn = btn
    out("")
  elseif state == 1 then
    if task == nil then
      out(fs.cd() .. "> ")
      state = 0
    else
      out(sys.readfromchild(task))
      out(sys.errorfromchild(task))
      if sys.childrunning(task) then
        if (input.hotkey() == "\x1b") then
          sys.killchild(task)
        end
      else
        sys.forgetchild(task)
        task = nil
      end
    end
  end
  lastinp = inp
end

function _shutdown()
  print("terminal terminated!")
end

function submit(line)
  local cmd = ""
  local args = parsecmd(line)
  out(line .. "\n")
  input.text("")
  input.clearhistory()
  if state == 0 then
    cmd = table.remove(args, 1)
    if cmd then
      if searchhistory(line) then
        table.remove(history, searchhistory(line))
      end
      table.insert(history, line)
    end
    histpos = #history + 1

    if (cmd == "endcli") then
      sys.exit(0)
    elseif (cmd == "cd") then
      if not fs.cd(args[1]) then
        out("Unable to change directory to " .. args[1] .. "\n")
      end
    elseif (cmd == "clear") then
      gfx.cls()
      termbottom = 0
      out("\n")
    elseif (cmd == "help") then
      out("Builtin commands: cd, clear, endcli, help\n\nsys:cmd/\n")
      task = sys.startchild("sys:cmd/dir.lua", {"sys:cmd/"})
    elseif cmd and cmd ~= "" then
      if task == nil then
        task = sys.startchild(cmd, args)
      end
      if task == nil then
        task = sys.startchild(cmd .. ".lua", args)
      end
      if task == nil then
        task = sys.startchild("sys:cmd/" .. cmd, args)
      end
      if task == nil then
        task = sys.startchild("sys:cmd/" .. cmd .. ".lua", args)
      end
      if task == nil then
        out("Unknown command " .. cmd .. "\n")
      end
    end
    state = 1
  elseif state == 1 then
    if task ~= nil then
      sys.writetochild(task, line .. "\n")
    end
  end
end

function out(data)
  local w, h
  local txt = input.text()
  local pos, sel = input.cursor()
  termline = termline .. wrap(data, view.size(scrn) / fontw)
  gfx.fgcolor(0)
  gfx.bar(0, termbottom - fontsize, scrnw, scrnh)
  gfx.fgcolor(1)
  -- repeat
  w, h = text.draw(termline, font, 0, termbottom - fontsize)
  h = termbottom - fontsize + h
  if h > scrnh then
    if h - scrnh < fontsize then
      scroll(h - scrnh)
    else
      scroll(fontsize)
    end
  end
  if string.find(termline, "\n") ~= nil then
    termline = string.sub(termline, string.find(termline, "\n") + 1)
    termbottom = termbottom + fontsize
    sys.stepinterval(16)
  elseif state == 1 then
    sys.stepinterval(128)
  else
    sys.stepinterval(-1)
  end
  -- until string.find(termline, "\n") == nil
  text.draw(txt, font, w, termbottom - fontsize)
  gfx.fgcolor(3)
  text.draw(string.sub(txt, 0, pos) .. "\x7f", font, w, termbottom - fontsize)
  text.draw(string.sub(txt, 0, pos + sel), font, w, termbottom - fontsize)
  if sel == 0 then
    gfx.fgcolor(2)
  else
    gfx.fgcolor(1)
  end
  text.draw(string.sub(txt, 0, pos + 1), font, w, termbottom - fontsize)
  gfx.fgcolor(1)
  text.draw(string.sub(txt, 0, pos), font, w, termbottom - fontsize)
end

function scroll(amount)
  image.copymode(0)
  image.copy(spare, 0, 0, 0, 0, scrnw, scrnh)
  gfx.cls()
  image.draw(spare, 0, -amount, 0, 0, scrnw, scrnh)
  termbottom = termbottom - amount
end

function wrap(txt, width)
  local col = 0
  local out = ""
  for i = 1, #txt do
    out = out .. string.sub(txt, i, i)
    col = col + 1
    if string.sub(txt, i, i) == "\n" then
      col = 0
    end
    if col == width then
      out = out .. "\n"
      col = 0
    end
  end
  return out
end

function parsecmd(line)
  local args = {}
  local arg = nil
  local term = " "
  local esc = false
  for i = 1, #line do
    local char = string.sub(line, i, i)
    if esc then
      arg = arg .. char
      esc = false
    elseif char == term then
      if arg ~= nil then
        table.insert(args, arg)
        arg = nil
        term = " "
      end
    elseif term == " " and (char == '"' or char == "'") then
      term = char
      arg = arg or ""
    else
      arg = arg or ""
      if char == "\\" then
        esc = true
      else
        arg = arg .. char
      end
    end
  end
  if arg ~= nil then
    table.insert(args, arg)
  end
  return args
end

function searchhistory(line)
  for i = 1, #history do
    if history[i] == line then
      return i
    end
  end
  return nil
end

function tabcomplete(line, options)
  local tabpos = string.find(line, "\t")
  if not tabpos then
    return line
  end
  local rest = string.sub(line, tabpos + 1)
  local args = parsecmd(string.sub(line, 1, tabpos - 1))
  local arg = table.remove(args)
  if not arg then
    return line
  end
  for i = 1, #options do
    local opt = options[i]
    if string.lower(string.sub(opt, 1, #arg)) == string.lower(arg) then
      arg = opt
    end
  end
  table.insert(args, arg)
  line = ""
  for i = 1, #args do
    arg = args[i]
    line = line .. string.gsub(arg, " ", "\\ ") .. " "
  end
  line = line .. rest
  return line
end
