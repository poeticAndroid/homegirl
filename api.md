# Lua API overview
##  _basic_
    dofile(filename): result
    loadfile(filename): function
    print(message)
    require(filename): module
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
    fs.read(filename): string
    fs.write(filename, string)
    fs.delete(filename)
    fs.list(dirname)
    fs.cd([dirname]): dirname
    fs.mkdir(dirname)
##  gfx
    gfx.cls()
    gfx.palette(color[, red, green, blue]): red, green, blue
    gfx.fgcolor([color]): color
    gfx.bgcolor([color]): color
    gfx.pixel(x, y[, color]): color
    gfx.plot(x, y)
    gfx.bar(x, y, width, height)
    gfx.line(x1, y1, x2, y2)
##  image
    image.new(width, height, colorbits): img
    image.load(filename): img
    image.loadanimation(filename): img[]
    image.size(img): width, height
    image.duration(img): height
    image.copymode([mode]): mode
    image.draw(img, x, y, imgx, imgy, width, height)
    image.copy(img, x, y, imgx, imgy, width, height)
    image.usepalette(img)
    image.copypalette(img)
    image.forget(img)
##  input
    input.text([text]): text
    input.cursor([pos, selected]): pos, selected
    input.hotkey(): hotkey
    input.mouse(): x, y, btn
    input.gamepad([player]): btn
##  sys
    sys.exit([code])
    sys.exec(filename[, args[][, cwd]]): success
    sys.startchild(filename[, args[]]): child
    sys.childrunning(child): bool
    sys.childexitcode(child): int
    sys.writetochild(child, str)
    sys.readfromchild(child): str
    sys.errorfromchild(child): str
    sys.killchild(child)
    sys.forgetchild(child)
##  text
    text.loadfont(filename): font
    text.copymode([mode]): mode
    text.draw(text, font, x, y): width, height
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
