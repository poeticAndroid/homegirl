createscreen(0, 3)
bgcolor(0)
setcolor(1, 15, 15, 15)

px = 160
py = 90

function _step()
  cls()
  btn = gamebtn()
  if btn & 1 > 0 then
    px = px + 1
  end
  if btn & 2 > 0 then
    px = px - 1
  end
  if btn & 4 > 0 then
    py = py - 1
  end
  if btn & 8 > 0 then
    py = py + 1
  end
  if btn & 16 > 0 then
    setcolor(1, 0, 15, 0)
  end
  if btn & 32 > 0 then
    setcolor(1, 15, 0, 0)
  end
  if btn & 64 > 0 then
    setcolor(1, 0, 0, 15)
  end
  if btn & 128 > 0 then
    setcolor(1, 15, 15, 0)
  end
  bar(px, py, 16, 16)
end
