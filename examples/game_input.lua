screendrag = require("./examples/screendrag")
players = {
  {
    x = -8,
    y = -12
  },
  {
    x = -32,
    y = -12
  },
  {
    x = 16,
    y = -12
  }
}

function _init()
  font = text.loadfont("./examples/fonts/Victoria.8b.gif")
  scrn = view.newscreen(5, 2)
  gfx.bgcolor(0)
  gfx.palette(1, 0, 7, 15)
  gfx.palette(2, 0, 7, 15)
  gfx.palette(3, 0, 7, 15)
  local w, h = view.size(scrn)
  for pn = 0, 2, 1 do
    p = players[1 + pn]
    p.x = p.x + w / 2
    p.y = p.y + h / 2
  end
end

function _step()
  gfx.cls()
  for pn = 0, 2, 1 do
    p = players[1 + pn]
    btn = input.gamepad(pn)
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
    gfx.fgcolor(1 + pn)
    text.draw(pn, font, p.x + 4, p.y - 8)
    gfx.bar(p.x, p.y, 16, 16)
    gfx.fgcolor(0)
    if btn & 16 > 0 then
      gfx.palette(1 + pn, 0, 15, 0)
      text.draw("A", font, p.x, p.y)
    end
    if btn & 32 > 0 then
      gfx.palette(1 + pn, 15, 0, 0)
      text.draw("B", font, p.x + 8, p.y)
    end
    if btn & 64 > 0 then
      gfx.palette(1 + pn, 0, 0, 15)
      text.draw("X", font, p.x, p.y + 8)
    end
    if btn & 128 > 0 then
      gfx.palette(1 + pn, 15, 15, 0)
      text.draw("Y", font, p.x + 8, p.y + 8)
    end
  end
  screendrag.step(scrn)
end
