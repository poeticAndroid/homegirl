dofile("./examples/screendrag.lua")

scrn = view.newscreen(15, 5)

function _step(t)
  for y = 0, 360 do
    for x = 0, 640 do
      gfx.fgcolor(math.random(0, 255))
      gfx.plot(x, y)
    end
  end
  dragscreen(scrn)
end
