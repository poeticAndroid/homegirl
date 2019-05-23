dofile("./examples/screendrag.lua")

scrn = createscreen(0, 4)
moveviewport(scrn, 0, 0)

x = 0
y = 0
dx = 1
dy = 0
c = 0

function _step()
  mx = mousex()
  my = mousey()
  y = y - 1
  local c = 0
  while x + y ~= 0 do
    x = x + dx
    y = y + dy
    c = c + 1
    fgcolor(c % 16)
    line(mx, my, x, y)
    if x > 319 then
      x = x - 1
      dx = 0
      dy = 1
    end
    if y > 179 then
      y = y - 1
      dx = -1
      dy = 0
    end
    if x < 0 then
      x = x + 1
      dx = 0
      dy = -1
    end
    if y < 0 then
      y = y + 1
      dx = 1
      dy = 0
    end
  end
  _cycle()
  dragscreen(scrn)
end

function _cycle()
  c = c + 1
  for i = 0, 15 do
    setcolor(i, i + c, i + c, i + c)
  end
end
