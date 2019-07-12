mode = 0
scrn = view.newscreen(mode, 1)
print("mode\twidth\theight\t|  mode\twidth\theight")
sys.stepinterval(0)

function _step()
  view.screenmode(scrn, mode, 1)
  width, height = view.size(scrn)
  view.screenmode(scrn, 16 + mode, 1)
  width2, height2 = view.size(scrn)
  print(mode .. "\t" .. width .. "\t" .. height .. "\t|  " .. 16 + mode .. "\t" .. width2 .. "\t" .. height2)
  mode = mode + 1
end
