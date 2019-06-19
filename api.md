    /// dofile(filename)
    /// loadfile(filename)
    /// print(message)
    /// require(filename)
    /// sys.exit(code)
    /// sys.exec(filename)
    /// view.createscreen(mode, colorbits): id
    /// view.changescreenmode(screenID, mode, colorbits)
    /// view.createviewport(parent, left, top, width, height): id
    /// view.activeviewport(vpID)
    /// view.moveviewport(vpID, left, top)
    /// view.resizeviewport(vpID, left, top)
    /// view.showviewport(vpID, visible)
    /// view.viewportleft(vpID): left
    /// view.viewporttop(vpID): top
    /// view.viewportwidth(vpID): width
    /// view.viewportheight(vpID): height
    /// view.viewportfocused(vpID): focused
    /// view.focusviewport(vpID)
    /// view.removeviewport(vpID)
    /// input.getinputtext(): text
    /// input.getinputpos(): position
    /// input.getinputselected(): selection
    /// input.setinputtext(text)
    /// input.setinputpos(pos)
    /// input.setinputselected(selected)
    /// input.hotkey(): hotkey
    /// input.mousex(): x
    /// input.mousey(): y
    /// input.mousebtn(): btn
    /// input.gamebtn(player): btn
    /// audio.createsample(): id
    /// audio.loadsample(filename): id
    /// audio.playsample(channel, smplID)
    /// audio.setsamplerate(channel, samplerate)
    /// audio.setvolume(channel, volume)
    /// audio.setsampleloop(channel, start, end)
    /// audio.editsample(smplID, pos, value)
    /// audio.editsamplerate(smplID, samplerate)
    /// audio.editsampleloop(smplID, start, end)
    /// audio.forgetsample(smplID)
    /// image.createimage(width, height, colorbits): id
    /// image.loadimage(filename): id
    /// image.loadanimation(filename): id
    /// image.imagewidth(imgID): width
    /// image.imageheight(imgID): height
    /// image.imageduration(imgID): height
    /// image.copymode(mode)
    /// image.drawimage(imgID, x, y, imgx, imgy, width, height)
    /// image.copyimage(imgID, x, y, imgx, imgy, width, height)
    /// image.copypalette(imgID)
    /// image.usepalette(imgID)
    /// image.forgetimage(imgID)
    /// gfx.cls()
    /// gfx.setcolor(color, red, green, blue)
    /// gfx.getcolor(color, channel): value
    /// gfx.fgcolor(index)
    /// gfx.bgcolor(index)
    /// gfx.pget(x, y): color
    /// gfx.plot(x, y)
    /// gfx.bar(x, y, width, height)
    /// gfx.line(x1, y1, x2, y2)
    /// text.loadfont(filename): id
    /// text.forgetfont(imgID)
    /// text.text(text, font, x, y): width
