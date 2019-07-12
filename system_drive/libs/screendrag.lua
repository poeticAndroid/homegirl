local screendrag = {
  state = 0
}

local gfx = NIL
local image = NIL

function screendrag.step(scrn)
  local x, y, btn = input.mouse()
  if btn == 0 then
    screendrag.state = 0
  end
  if screendrag.state == 0 then
    if btn == 1 then
      if y > 10 then
        screendrag.state = -1
      else
        screendrag.state = 1
      end
    end
  elseif screendrag.state > 0 then
    local left, top = view.position(scrn)
    view.position(scrn, 0, top + y - 5)
  end
  if input.hotkey() == "q" then
    sys.exit(0)
  end
end

return screendrag
