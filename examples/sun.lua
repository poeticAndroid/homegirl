createscreen(0, 4)

x = 0
y = 0
dx = 1
dy = 0
c = 0

function _step()
  y = y - 1
  c = c + 7
  while x + y ~= 0 do
    x = x + dx
    y = y + dy
    c = c + 1
    fgcolor(c % 16)
    line(160, 90, x, y)
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
end
