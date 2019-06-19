_screendragstate = 0

function dragscreen(scrn)
  if input.mousebtn() == 0 then
    _screendragstate = 0
  end
  if _screendragstate == 0 then
    if input.mousebtn() == 1 then
      if input.mousey() > 10 then
        _screendragstate = -1
      else
        _screendragstate = 1
      end
    end
  elseif _screendragstate > 0 then
    view.move(scrn, 0, view.top(scrn) + input.mousey())
  end
end
