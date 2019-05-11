scrn = createscreen(0, 5)
moveviewport(scrn, 0, 180)
pointer = loadimage("./examples/images/pointer.gif")
print("attempting to show an image!")

img = loadimage("./examples/images/Pharao.gif")
width = imagewidth(img)
height = imageheight(img)
usepalette(img)

x = -100
y = -170
function _step()
  drawimage(img, 160 - (width / 2), 90 - height / 2, 0, 0, width, height)
  bar(x, y, 100, 100)
  x = x + 1
  y = y + 1
  drawimage(pointer, mousex(), mousey(), 0, 0, 16, 16)
  if y > 320 then
    x = -100
    y = -170
  end
  if mousebtn() > 0 then
    moveviewport(scrn, 0, viewporttop(scrn) + mousey())
  end
end
