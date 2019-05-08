createscreen(0, 5)
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
end
