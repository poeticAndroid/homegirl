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
    audio.channelfreq(channel[, freq]): freq
    audio.channelvolume(channel[, volume]): volume
    audio.channelloop(channel[, start, end]): start, end
    audio.sample(smplID, pos[, value]): value
    audio.samplefreq(smplID[, freq]): freq
    audio.sampleloop(smplID[, start, end]): start, end
    audio.forget(smplID)
##  fs
    -- not yet implemented
##  gfx
    gfx.cls()
    gfx.palette(color[, red, green, blue]): red, green, blue
    gfx.fgcolor([index]): index
    gfx.bgcolor([index]): index
    gfx.pixel(x, y[, color]): color
    gfx.plot(x, y): color
    gfx.bar(x, y, width, height)
    gfx.line(x1, y1, x2, y2)
##  image
    image.new(width, height, colorbits): id
    image.load(filename): id
    image.loadanimation(filename): id
    image.imagewidth(imgID): width
    image.imageheight(imgID): height
    image.imageduration(imgID): height
    image.copymode([mode]): mode
    image.draw(imgID, x, y, imgx, imgy, width, height)
    image.copy(imgID, x, y, imgx, imgy, width, height)
    image.usepalette(imgID)
    image.copypalette(imgID)
    image.forget(imgID)
##  input
    input.text([text]): text
    input.cursor([pos]): pos
    input.selected([selected]): selected
    input.hotkey(): hotkey
    input.mousex(): x
    input.mousey(): y
    input.mousebtn(): btn
    input.gamebtn([player]): btn
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
    view.activate(vpID)
    view.position(vpID[, left, top]): left, top
    view.size(vpID[, width, height]): width, height
    view.visible(vpID[, visible]): visible
    view.focused(vpID[, focused]): focused
    view.remove(vpID)
