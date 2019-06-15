    /// exit(code)
    /// exec(filename)
    /// print(message)
    /// createscreen(mode, colorbits): id
    /// changescreenmode(screenID, mode, colorbits)
    /// createviewport(parent, left, top, width, height): id
    /// activeviewport(vpID)
    /// moveviewport(vpID, left, top)
    /// resizeviewport(vpID, left, top)
    /// showviewport(vpID, visible)
    /// viewportleft(vpID): left
    /// viewporttop(vpID): top
    /// viewportwidth(vpID): width
    /// viewportheight(vpID): height
    /// viewportfocused(vpID): focused
    /// focusviewport(vpID)
    /// removeviewport(vpID)
    /// getinputtext(): text
    /// getinputpos(): position
    /// getinputselected(): selection
    /// setinputtext(text)
    /// setinputpos(pos)
    /// setinputselected(selected)
    /// hotkey(): hotkey
    /// mousex(): x
    /// mousey(): y
    /// mousebtn(): btn
    /// gamebtn(player): btn
    /// createsample(): id
    /// loadsample(filename): id
    /// playsample(channel, smplID)
    /// setsamplerate(channel, samplerate)
    /// setvolume(channel, volume)
    /// setsampleloop(channel, start, end)
    /// editsample(smplID, pos, value)
    /// editsamplerate(smplID, samplerate)
    /// editsampleloop(smplID, start, end)
    /// forgetsample(smplID)
    /// createimage(width, height, colorbits): id
    /// loadimage(filename): id
    /// loadanimation(filename): id
    /// imagewidth(imgID): width
    /// imageheight(imgID): height
    /// imageduration(imgID): height
    /// copymode(mode)
    /// drawimage(imgID, x, y, imgx, imgy, width, height)
    /// copyimage(imgID, x, y, imgx, imgy, width, height)
    /// copypalette(imgID)
    /// usepalette(imgID)
    /// forgetimage(imgID)
    /// cls()
    /// setcolor(color, red, green, blue)
    /// getcolor(color, channel): value
    /// fgcolor(index)
    /// bgcolor(index)
    /// pget(x, y): color
    /// plot(x, y)
    /// bar(x, y, width, height)
    /// line(x1, y1, x2, y2)
    /// loadfont(filename): id
    /// forgetfont(imgID)
    /// text(text, font, x, y): width
