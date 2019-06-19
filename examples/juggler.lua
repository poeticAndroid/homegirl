dofile("./examples/screendrag.lua")

scrn = view.createscreen(0, 5)

font = text.loadfont("./examples/fonts/Victoria.8b.gif")
anim = image.loadanimation("./examples/images/juggler32.gif")
ding = audio.loadsample("./examples/sounds/juggler.wav")
frame = 0
nextFrame = 0
mx = 0
my = 0

function _init()
  image.usepalette(anim[1])
end

function _step(t)
  if t - nextFrame > 100 then
    nextFrame = t
  end
  if t < nextFrame then
    return
  end
  frame = frame + 1
  if frame > #anim then
    frame = 1
    if view.viewporttop(scrn) < 256 then
      audio.playsample(0, ding)
      audio.playsample(3, ding)
      for c = 0, 3 do
        audio.setvolume(c, 63 - view.viewporttop(scrn) / 4)
      end
    end
  end
  gfx.bar(0, 0, 320, 180)
  image.drawimage(anim[frame], 0, 0, 0, 0, 320, 180)
  if input.mousebtn() > 0 then
    gfx.line(mx, my, input.mousex(), input.mousey())
    image.copyimage(anim[frame], 0, 0, 0, 0, 320, 180)
  end
  mx = input.mousex()
  my = input.mousey()
  nextFrame = nextFrame + image.imageduration(anim[frame])
  dragscreen(scrn)
end
