# Lua API overview
##  _basic_
    dofile(filename): result
    loadfile(filename): function
    print(message)
    require(filename): module
##  audio
    audio.new(): sampl
    audio.load(filename): sampl
    audio.save(filename, sampl): success
    audio.play(channel, sampl)
    audio.channelfreq(channel[, freq]): freq
    audio.channelhead(channel[, pos]): pos
    audio.channelvolume(channel[, volume]): volume
    audio.channelloop(channel[, start, end]): start, end
    audio.samplevalue(sampl, pos[, value]): value
    audio.samplelength(sampl[, length]): length
    audio.samplefreq(sampl[, freq]): freq
    audio.sampleloop(sampl[, start, end]): start, end
    audio.forget(sampl)
##  fs
    fs.isfile(filename): confirmed
    fs.isdir(filename): confirmed
    fs.read(filename): string
    fs.write(filename, string): success
    fs.delete(filename): success
    fs.list(dirname): entries[]
    fs.drives(): drivenames[]
    fs.cd([dirname]): dirname
    fs.mkdir(dirname): success
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
    image.duration(img): milliseconds
    image.copymode([mode]): mode
    image.draw(img, x, y, imgx, imgy, width, height)
    image.copy(img, x, y, imgx, imgy, width, height)
    image.usepalette(img)
    image.copypalette(img)
    image.forget(img)
##  input
    input.text([text]): text
    input.selected([text]): text
    input.cursor([pos, selected]): pos, selected
    input.clearhistory()
    input.hotkey(): hotkey
    input.mouse(): x, y, btn
    input.gamepad([player]): btn
##  sys
    sys.stepinterval([milliseconds]): milliseconds
    sys.listenv(): keys[]
    sys.env(key[, value]): value
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
