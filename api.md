# Lua API overview
##  _
    dofile(filename) -- not yet implemented
    loadfile(filename) -- not yet implemented
    print(message)
    require(filename) -- not yet implemented
##  audio
    audio.new(): sampl
    audio.load(filename): sampl
    audio.play(channel, sampl)
    audio.channelfreq(channel[, freq]): freq
    audio.channelvolume(channel[, volume]): volume
    audio.channelloop(channel[, start, end]): start, end
    audio.sample(sampl, pos[, value]): value
    audio.samplefreq(sampl[, freq]): freq
    audio.sampleloop(sampl[, start, end]): start, end
    audio.forget(sampl)
##  fs
    -- not yet implemented
##  gfx
    gfx.cls()
    gfx.palette(color[, red, green, blue]): red, green, blue
    gfx.fgcolor([color]): color
    gfx.bgcolor([color]): color
    gfx.pixel(x, y[, color]): color
    gfx.plot(x, y): color
    gfx.bar(x, y, width, height)
    gfx.line(x1, y1, x2, y2)
##  image
    image.new(width, height, colorbits): img
    image.load(filename): img
    image.loadanimation(filename): img[]
    image.imagewidth(img): width
    image.imageheight(img): height
    image.imageduration(img): height
    image.copymode([mode]): mode
    image.draw(img, x, y, imgx, imgy, width, height)
    image.copy(img, x, y, imgx, imgy, width, height)
    image.usepalette(img)
    image.copypalette(img)
    image.forget(img)
##  input
    input.text([text]): text
    input.cursor([pos]): pos
    input.selected([bytes]): bytes
    input.hotkey(): hotkey
    input.mouse(): x, y, btn
    input.gamepad([player]): btn
##  sys
    sys.exit([code])
    sys.exec(filename)
##  text
    text.loadfont(filename): font
    text.copymode([mode]): mode
    text.draw(text, font, x, y): width
    text.forgetfont(font)
##  view
    view.newscreen(mode, colorbits): view
    view.screenmode(view, mode, colorbits)
    view.new(parentview, left, top, width, height): view
    view.activate(view)
    view.position(view[, left, top]): left, top
    view.size(view[, width, height]): width, height
    view.visible(view[, isvisible]): isvisible
    view.focused(view[, isfocused]): isfocused
    view.remove(view)
