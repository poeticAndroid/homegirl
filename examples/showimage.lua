createscreen(0, 5)
print("attempting to show an image!")

img = loadimage("./examples/images/Pharao.gif")
width = imagewidth(img)
height = imageheight(img)
usepalette(img)
drawimage(img, 160 - (width / 2), 90 - height / 2, 0, 0, width, height)
