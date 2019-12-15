function _init()
  print("Memory used: " .. friendly(sys.memoryusage()))
end

function friendly(bytes)
  local units = bytes
  local measures = {"YiB", "ZiB", "EiB", "PiB", "TiB", "GiB", "MiB", "KiB"}
  local measure = "bytes"
  while units >= 1024 do
    units = units / 1024
    measure = table.remove(measures)
  end
  return string.format("%4.3f", units) .. " " .. measure
end
