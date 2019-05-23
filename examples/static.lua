dofile("./examples/screendrag.lua")

createscreen(3, 5)

function _step(t)
  for y = 0, 360 do
    for x = 0, 640 do
      fgcolor(math.random(0, 255))
      plot(x, y)
    end
  end
  dragscreen(scrn)
end
