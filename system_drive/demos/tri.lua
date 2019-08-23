local Screen = require(_DRIVE .. "libs/screen")
local pts = {
  {x = 8, y = 8},
  {x = 120, y = 64},
  {x = 1, y = 120},
  {x = 208, y = 8},
  {x = 320, y = 64},
  {x = 201, y = 120}
}
local moving
local anim
local frame = 0
local tex

function _init(args)
  scrn = Screen:new("Triangle demo", 10, 5)
  anim = image.load(_DIR .. "images/80wave.gif")
  scrn:usepalette(anim[1])
  scrn:autocolor()
  gfx.fgcolor(scrn:colors())
  sys.stepinterval(1000 / 30)
end
function _step(t)
  local mx, my, mbtn = input.mouse()
  if mbtn == 1 then
    if moving then
      pts[moving].x = mx
      pts[moving].y = my
    else
      moving = closestpt(mx, my)
    end
  else
    moving = nil
  end
  frame = frame + 1
  if frame > #anim then
    frame = 1
  end
  tex = anim[frame]
  gfx.cls()
  image.draw(tex, 0, 0, 0, 0, image.size(tex))
  gfx.line(pts[1].x, pts[1].y, pts[2].x, pts[2].y)
  gfx.line(pts[2].x, pts[2].y, pts[3].x, pts[3].y)
  gfx.line(pts[3].x, pts[3].y, pts[1].x, pts[1].y)
  image.tri(
    tex,
    pts[4].x,
    pts[4].y,
    pts[5].x,
    pts[5].y,
    pts[6].x,
    pts[6].y,
    pts[1].x,
    pts[1].y,
    pts[2].x,
    pts[2].y,
    pts[3].x,
    pts[3].y
  )
  if input.hotkey() == "\x1b" then
    sys.exit(0)
  end
  scrn:step()
end

function closestpt(x, y)
  local bestpt
  local bestlen = 1024
  for i, pt in pairs(pts) do
    local len = dist(x, y, pt)
    if len < bestlen then
      bestpt = i
      bestlen = len
    end
  end
  return bestpt
end

function dist(x, y, pt)
  local dx = math.abs(pt.x - x)
  local dy = math.abs(pt.y - y)
  return math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))
end
