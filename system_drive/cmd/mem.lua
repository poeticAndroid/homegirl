function _init()
  print("Memory used: " .. friendly(sys.memoryusage()))
end

function friendly(bytes)
  local units = bytes
  local type = "bytes"
  if units >= 1024 then
    units = units / 1024
    type = "KiB"
  end
  if units >= 1024 then
    units = units / 1024
    type = "MiB"
  end
  if units >= 1024 then
    units = units / 1024
    type = "GiB"
  end
  if units >= 1024 then
    units = units / 1024
    type = "TiB"
  end
  if units >= 1024 then
    units = units / 1024
    type = "PiB"
  end
  if units >= 1024 then
    units = units / 1024
    type = "EiB"
  end
  if units >= 1024 then
    units = units / 1024
    type = "ZiB"
  end
  if units >= 1024 then
    units = units / 1024
    type = "YiB"
  end
  return string.format("%4.3f", units) .. " " .. type
end
