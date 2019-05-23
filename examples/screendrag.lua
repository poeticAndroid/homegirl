_screendragstate = 0

function dragscreen(scrn)
  if mousebtn() == 0 then
    _screendragstate = 0
  end
  if _screendragstate == 0 then
    if mousebtn() == 1 then
      if mousey() > 10 then
        _screendragstate = -1
      else
        _screendragstate = 1
      end
    end
  elseif _screendragstate > 0 then
    moveviewport(scrn, 0, viewporttop(scrn) + mousey())
  end
end
