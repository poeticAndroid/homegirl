
function _step(t)
  for y = 0,180 do
    for x = 0,320 do
      setfgcolor(math.random(0,255))
      pset(x,y)
    end
  end
end

print("This is the program!")