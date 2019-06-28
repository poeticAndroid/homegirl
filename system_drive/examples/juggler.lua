screendrag = require("./screendrag")
scrn = view.newscreen(10, 5)

font = text.loadfont("./fonts/Victoria.8b.gif")
anim = image.loadanimation("./images/juggler32.gif")
ding = audio.load("./sounds/juggler.wav")
frame = 0
nextFrame = 0
_mx = 0
_my = 0

function _init()
  image.usepalette(anim[1])
end

function _step(t)
  local left, top = view.position(scrn)
  local mx, my, mbtn = input.mouse()
  if t - nextFrame > 100 then
    nextFrame = t
  end
  if t < nextFrame then
    return
  end
  frame = frame + 1
  if frame > #anim then
    frame = 1
    if top < 256 then
      audio.play(0, ding)
      audio.play(3, ding)
      for c = 0, 3 do
        audio.channelvolume(c, 63 - top / 4)
      end
    end
  end
  gfx.bar(0, 0, 320, 180)
  image.draw(anim[frame], 0, 0, 0, 0, 320, 180)
  if mbtn > 0 then
    gfx.line(_mx, _my, mx, my)
    image.copy(anim[frame], 0, 0, 0, 0, 320, 180)
  end
  _mx = mx
  _my = my
  nextFrame = nextFrame + image.imageduration(anim[frame])
  screendrag.step(scrn)
end
