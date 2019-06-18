dofile("./examples/screendrag.lua")

scrn = createscreen(0, 5)

font = loadfont("./examples/fonts/Victoria.8b.gif")
anim = loadanimation("./examples/images/juggler32.gif")
ding = loadsample("./examples/sounds/juggler.wav")
frame = 0
nextFrame = 0
mx = 0
my = 0

function _init()
  usepalette(anim[1])
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
    if viewporttop(scrn) < 256 then
    -- playsample(0, ding)
    -- playsample(3, ding)
    -- for c = 0, 3 do
    --   setvolume(c, 63 - viewporttop(scrn) / 4)
    -- end
    end
  end
  bar(0, 0, 320, 180)
  drawimage(anim[frame], 0, 0, 0, 0, 320, 180)
  if mousebtn() > 0 then
    line(mx, my, mousex(), mousey())
    copyimage(anim[frame], 0, 0, 0, 0, 320, 180)
  end
  mx = mousex()
  my = mousey()
  nextFrame = nextFrame + imageduration(anim[frame])
  dragscreen(scrn)
end
