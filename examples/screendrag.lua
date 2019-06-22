_screendragstate = 0

function dragscreen(scrn)
  local x, y, btn = input.mouse()
  if btn == 0 then
    _screendragstate = 0
  end
  if _screendragstate == 0 then
    if btn == 1 then
      if y > 10 then
        _screendragstate = -1
      else
        _screendragstate = 1
      end
    end
  elseif _screendragstate > 0 then
    local left, top = view.position(scrn)
    view.position(scrn, 0, top + y)
  end
end
