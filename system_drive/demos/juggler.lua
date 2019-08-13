Screen = require("sys:libs/screen")

frame = 0
_mx = 0
_my = 0

function _init(args)
  scrn = Screen:new("Juggler demo", 10, 5)
  scrn:colors(15, 0)
  if args[1] == nil then
    anim = image.load("images/juggler32.gif")
  else
    anim = image.load(args[1])
  end
  ding = audio.load("./sounds/juggler.wav")
  scrn:usepalette(anim[1])
end

function _step(t)
  local left, top = view.position(scrn.rootvp)
  local mx, my, mbtn = input.mouse()
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
  sys.stepinterval(image.duration(anim[frame]))
  if input.hotkey() == "\x1b" then
    sys.exit(0)
  end
  scrn:step()
end
