scrn = view.newscreen(11, 2)
scrnw, scrnh = view.size(scrn)
spare = image.new(scrnw, scrnh, 4)
font = text.loadfont("sys:fonts/Victoria.8b.gif")
fontsize = 8
termline = ""
termbottom = fontsize
state = 1
task = nil

function _init()
  gfx.palette(0, 0, 5, 10)
  gfx.palette(1, 15, 15, 15)
  gfx.palette(2, 0, 0, 2)
  gfx.palette(3, 15, 8, 0)

  out("Homegirl Shell\n\n")
end

function _step()
  local inp = input.text()
  if string.find(inp, "\n") ~= nil then
    submit(string.gsub(inp, "\n", ""))
  end
  if state == 0 then
    out("")
  elseif state == 1 then
    if task == nil then
      out(fs.cd() .. "> ")
      state = 0
    else
      out(sys.readfromchild(task))
      out(sys.errorfromchild(task))
      if sys.childrunning(task) then
        if (input.hotkey() == "c") then
          sys.killchild(task)
        end
      else
        sys.forgetchild(task)
        task = nil
      end
    end
  end
end

function _shutdown()
  print("terminal terminated!")
end

function submit(line)
  local cmd = ""
  local args = {}
  input.text("")
  if state == 0 then
    while string.find(line, " ") ~= nil do
      table.insert(args, string.sub(line, 1, string.find(line, " ") - 1))
      line = string.sub(line, string.find(line, " ") + 1)
    end
    table.insert(args, line)
    cmd = table.remove(args, 1)
    out(cmd .. " " .. table.concat(args, " ") .. "\n")

    if (cmd == "exit") then
      sys.exit(0)
    elseif (cmd == "cd") then
      fs.cd(args[1])
    elseif cmd ~= "" then
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
        out("unknown command!\n")
      end
    end
    state = 1
  elseif state == 1 then
    if task ~= nil then
      sys.writetochild(task, line .. "\n")
      out(line .. "\n")
    end
  end
end

function out(data)
  local w, h
  local txt = input.text()
  local pos, sel = input.cursor()
  termline = termline .. data
  gfx.fgcolor(0)
  gfx.bar(0, termbottom - fontsize, scrnw, scrnh)
  gfx.fgcolor(1)
  repeat
    w, h = text.draw(termline, font, 0, termbottom - fontsize)
    h = termbottom - fontsize + h
    if h > scrnh then
      scroll(fontsize)
    end
    if string.find(termline, "\n") ~= nil then
      termline = string.sub(termline, string.find(termline, "\n") + 1)
      termbottom = termbottom + fontsize
    end
  until string.find(termline, "\n") == nil
  gfx.fgcolor(2)
  text.draw(txt, font, w + 1, termbottom - fontsize + 1)
  gfx.fgcolor(1)
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
