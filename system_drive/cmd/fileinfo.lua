wdays = {"monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"}
months = {"jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"}
function _init(args)
  print("Filename: "..args[1])
  size = fs.size(args[1])
  print("Size: "..size.." bytes")
  th,tm,ts,tu = fs.time(args[1])
  dy,dm,dd,dw = fs.date(args[1])
  print(string.format("Modified: %d-%s-%02d %s %d:%02d:%02d UTC%+gh", dy, months[dm], dd, wdays[dw], th, tm, ts, tu / 60))
end
