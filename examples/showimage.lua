createscreen(0, 5)
print("attempting to show an image!")

img = loadimage("./examples/images/80wave.gif")
usepalette(img)
drawimage(img, 160 - 64, 90 - 64, 0, 0, 128, 128)
