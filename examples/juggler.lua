dofile("./examples/screendrag.lua")

scrn = view.newscreen(0, 5)

font = text.loadfont("./examples/fonts/Victoria.8b.gif")
anim = image.loadanimation("./examples/images/juggler32.gif")
ding = audio.load("./examples/sounds/juggler.wav")
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
    if view.top(scrn) < 256 then
      audio.play(0, ding)
      audio.play(3, ding)
      for c = 0, 3 do
        audio.setvolume(c, 63 - view.top(scrn) / 4)
      end
    end
  end
  gfx.bar(0, 0, 320, 180)
  image.draw(anim[frame], 0, 0, 0, 0, 320, 180)
  if input.mousebtn() > 0 then
    gfx.line(mx, my, input.mousex(), input.mousey())
    image.copy(anim[frame], 0, 0, 0, 0, 320, 180)
  end
  mx = input.mousex()
  my = input.mousey()
  nextFrame = nextFrame + image.imageduration(anim[frame])
  dragscreen(scrn)
end
