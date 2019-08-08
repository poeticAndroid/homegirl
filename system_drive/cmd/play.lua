screendrag = require("sys:libs/screendrag")

function _init(args)
  scrn = view.newscreen(15, 1)
  snd = audio.load(args[1])
  if snd == nil then
    print("Couldn't play file " .. args[1])
    return sys.exit(1)
  end
  sndlen = audio.samplelength(snd)
  lasthead = 0
  audio.play(0, snd)
  audio.play(3, snd)
  print("Playing " .. args[1] .. " at " .. audio.samplefreq(snd) .. " Hz")
  sys.stepinterval(1000 / 60)
  gfx.palette(1, 15, 15, 15)
  scrnw, scrnh = view.size(scrn)
end

function _step()
  local head = audio.channelhead(0)
  local speed = head - lasthead
  local stp = scrnw / speed
  local x = scrnw
  local h = head
  if h >= sndlen then
    h = sndlen - 1
  end
  lineto(scrnw, scrnh / 2)
  gfx.cls()
  while x >= 0 and h >= 0 do
    lineto(x, scrnh / 2 + audio.samplevalue(snd, h))
    x = x - stp
    h = h - 1
  end
  if audio.channelfreq(0) == 0 then
    sys.exit(0)
  end
  lasthead = head
  screendrag.step(scrn)
end

function lineto(x, y)
  gfx.line(ltx, lty, x, y)
  ltx = x
  lty = y
end
