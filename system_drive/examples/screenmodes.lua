mode = 0
scrn = view.newscreen(mode, 1)
print("mode\twidth\theight")

function _step()
  sys.stepinterval(0)
  view.screenmode(scrn, mode, 1)
  width, height = view.size(scrn)
  print(mode .. "\t" .. width .. "\t" .. height)
  mode = mode + 1
end
