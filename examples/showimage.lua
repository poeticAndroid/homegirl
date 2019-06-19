dofile("./examples/screendrag.lua")

scrn = view.createscreen(0, 5)
pointer = image.loadimage("./examples/images/pointer.gif")

img = image.loadimage("./examples/images/Pharao.gif")
width = image.imagewidth(img)
height = image.imageheight(img)
image.usepalette(img)

x = -100
y = -170
function _step()
  image.drawimage(img, 160 - (width / 2), 90 - height / 2, 0, 0, width, height)
  gfx.bar(x, y, 100, 100)
  x = x + 1
  y = y + 1
  image.drawimage(pointer, input.mousex(), input.mousey(), 0, 0, 16, 16)
  if y > 320 then
    x = -100
    y = -170
  end
  dragscreen(scrn)
end
