createscreen(0, 4)

s = 10

for i = 0, 319, s do
  fgcolor(i % 16)
  line(160, 90, i, 0)
end

for i = 0, 179, s do
  fgcolor(i % 16)
  line(160, 90, 320, i)
end

for i = 319, 0, -s do
  fgcolor(i % 16)
  line(160, 90, i, 180)
end

for i = 179, 0, -s do
  fgcolor(i % 16)
  line(160, 90, 0, i)
end
