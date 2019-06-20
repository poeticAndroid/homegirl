# Lua API overview
##  _
    dofile(filename) -- not yet implemented
    loadfile(filename) -- not yet implemented
    print(message)
    require(filename) -- not yet implemented
##  audio
    audio.new(): id
    audio.load(filename): id
    audio.play(channel, smplID)
    audio.setrate(channel, samplerate)
    audio.setvolume(channel, volume)
    audio.setloop(channel, start, end)
    audio.edit(smplID, pos, value)
    audio.editrate(smplID, samplerate)
    audio.editloop(smplID, start, end)
    audio.forget(smplID)
##  fs
    -- not yet implemented
##  gfx
    gfx.cls()
    gfx.setcolor(color, red, green, blue)
    gfx.getcolor(color, channel): value
    gfx.fgcolor(index)
    gfx.bgcolor(index)
    gfx.pget(x, y): color
    gfx.plot(x, y)
    gfx.bar(x, y, width, height)
    gfx.line(x1, y1, x2, y2)
##  image
    image.new(width, height, colorbits): id
    image.load(filename): id
    image.loadanimation(filename): id
    image.imagewidth(imgID): width
    image.imageheight(imgID): height
    image.imageduration(imgID): height
    image.copymode(mode)
    image.draw(imgID, x, y, imgx, imgy, width, height)
    image.copy(imgID, x, y, imgx, imgy, width, height)
    image.copypalette(imgID)
    image.usepalette(imgID)
    image.forget(imgID)
##  input
    input.gettext(): text
    input.getpos(): position
    input.getselected(): selection
    input.settext(text)
    input.setpos(pos)
    input.setselected(selected)
    input.hotkey(): hotkey
    input.mousex(): x
    input.mousey(): y
    input.mousebtn(): btn
    input.gamebtn(player): btn
##  sys
    sys.exit(code)
    sys.exec(filename)
##  text
    text.loadfont(filename): id
    text.forgetfont(imgID)
    text.text(text, font, x, y): width
##  view
    view.newscreen(mode, colorbits): id
    view.screenmode(screenID, mode, colorbits)
    view.new(parent, left, top, width, height): id
    view.active(vpID)
    view.move(vpID, left, top)
    view.resize(vpID, left, top)
    view.show(vpID, visible)
    view.left(vpID): left
    view.top(vpID): top
    view.width(vpID): width
    view.height(vpID): height
    view.isfocused(vpID): focused
    view.focus(vpID)
    view.remove(vpID)
