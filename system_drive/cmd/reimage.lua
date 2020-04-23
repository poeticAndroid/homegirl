function _init(args)
  if #args < 1 then
    print("Usage: reimage <source> <destination>")
    return sys.exit(1)
  end
  anim = image.load(args[1])
  if anim == nil then
    print("Couldn't load file " .. args[1])
    return sys.exit(1)
  end
  scrn = view.newscreen(0, 8)
  w, h = image.size(anim[1])
  view.new(scrn, 0, 0, w, h)
  bpp = minbpp(anim)
  for i = 1, #anim do
    gfx.cls()
    image.usepalette(anim[i])
    image.draw(anim[i], 0, 0, 0, 0, w, h)
    image.forget(anim[i])
    anim[i] = image.new(w, h, bpp)
    image.copypalette(anim[i])
    image.copy(anim[i], 0, 0, 0, 0, w, h)
  end
  image.save(args[#args], anim)
end

function minbpp(anim)
  local colors, c, bpp = 0, 0, 1
  local w, h = image.size(anim[1])
  for i = 1, #anim do
    gfx.cls()
    image.draw(anim[i], 0, 0, 0, 0, image.size(anim[i]))
    for y = 1, h do
      for x = 1, w do
        c = gfx.pixel(x - 1, y - 1)
        if c > colors then
          colors = c
        end
      end
    end
  end
  colors = colors + 1
  while math.pow(2, bpp) < colors do
    bpp = bpp + 1
  end
  return bpp
end
