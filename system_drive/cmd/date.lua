wdays = {"sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"}
months = {"jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"}

function _init()
  h, m, s, off = sys.time()
  yr, mn, dt, wd = sys.date()
  print(string.format("%d-%s-%02d %s %d:%02d:%02d UTC%+gh", yr, months[mn], dt, wdays[wd + 1], h, m, s, off / 60))
end
