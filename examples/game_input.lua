dofile("./examples/screendrag.lua")
players = {
  {
    x = 160,
    y = 32
  },
  {
    x = 80,
    y = 32
  },
  {
    x = 240,
    y = 32
  }
}

function _init()
  font = loadfont("./examples/fonts/Victoria.8b.gif")
  scrn = createscreen(0, 2)
  bgcolor(0)
  copymode(2)
  setcolor(1, 0, 7, 15)
  setcolor(2, 0, 7, 15)
  setcolor(3, 0, 7, 15)
end

function _step()
  cls()
  for pn = 0, 2, 1 do
    p = players[1 + pn]
    btn = gamebtn(pn)
    if btn & 1 > 0 then
      p.x = p.x + 1
    end
    if btn & 2 > 0 then
      p.x = p.x - 1
    end
    if btn & 4 > 0 then
      p.y = p.y - 1
    end
    if btn & 8 > 0 then
      p.y = p.y + 1
    end
    fgcolor(1 + pn)
    text(pn, font, p.x + 4, p.y - 8)
    bar(p.x, p.y, 16, 16)
    fgcolor(0)
    if btn & 16 > 0 then
      setcolor(1 + pn, 0, 15, 0)
      text("A", font, p.x, p.y)
    end
    if btn & 32 > 0 then
      setcolor(1 + pn, 15, 0, 0)
      text("B", font, p.x + 8, p.y)
    end
    if btn & 64 > 0 then
      setcolor(1 + pn, 0, 0, 15)
      text("X", font, p.x, p.y + 8)
    end
    if btn & 128 > 0 then
      setcolor(1 + pn, 15, 15, 0)
      text("Y", font, p.x + 8, p.y + 8)
    end
  end
  dragscreen(scrn)
end
