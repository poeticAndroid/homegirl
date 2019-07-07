screendrag = require("sys:libs/screendrag")

function _init(args)
  mode = 0
  scrn = view.newscreen(mode, 8)
  anim = image.loadanimation(args[1])
  width, height = image.size(anim[1])
  scrnw, scrnh = view.size(scrn)
  while width > scrnw do
    mode = mode + 5
    scrnw = scrnw * 2
    scrnh = scrnh * 2
  end
  while height > scrnh do
    mode = mode + 5
    scrnw = scrnw * 2
    scrnh = scrnh * 2
  end
  if mode > 15 then
    mode = 15
  end
  view.screenmode(scrn, mode, 8)
  scrnw, scrnh = view.size(scrn)
  image.copymode(0)
  x = scrnw / 2 - width / 2
  y = scrnh / 2 - height / 2
  f = 0
  nf = 0
end

function _step(t)
  local mx, my, mbtn = input.mouse()
  local btn = input.gamepad(pn)
  gfx.cls()
  if nf == 0 then
    nf = t
  end
  if t > nf then
    f = f + 1
    nf = nf + image.duration(anim[f])
  end
  if f > #anim then
    f = 1
  end
  if mbtn == 1 then
    x = mx + rx
    y = my + ry
  else
    rx = x - mx
    ry = y - my
  end
  if btn & 1 > 0 then
    x = x - 1
  end
  if btn & 2 > 0 then
    x = x + 1
  end
  if btn & 4 > 0 then
    y = y + 1
  end
  if btn & 8 > 0 then
    y = y - 1
  end
  image.usepalette(anim[f])
  image.draw(anim[f], x, y, 0, 0, width, height)
  screendrag.step(scrn)
end
