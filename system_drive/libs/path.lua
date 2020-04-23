local path = {}

function path.split(pathname)
  pathname = path.notrailslash(pathname)
  local segs = {}
  local i = string.find(pathname, ":")
  if i then
    table.insert(segs, string.sub(pathname, 1, i))
    pathname = string.sub(pathname, i + 1)
  end
  i = string.find(pathname, "/")
  while i do
    table.insert(segs, string.sub(pathname, 1, i - 1))
    pathname = string.sub(pathname, i + 1)
    i = string.find(pathname, "/")
  end
  if #pathname > 0 then
    table.insert(segs, pathname)
  end
  return segs
end

function path.resolve(...)
  local segs = {}
  local rels = {...}
  for i, rel in ipairs(rels) do
    local _segs = path.split(rel)
    for i, seg in ipairs(_segs) do
      if string.sub(seg, -1) == ":" then
        segs = {seg}
      elseif seg == "" then
        segs = {segs[1]}
      elseif seg == "." then
      elseif seg == ".." then
        table.remove(segs)
      else
        table.insert(segs, seg)
      end
    end
  end
  local abspath = ""
  for i, seg in ipairs(segs) do
    if i > 2 then
      abspath = abspath .. "/"
    end
    abspath = abspath .. seg
  end
  return abspath
end

function path.basename(pathname)
  pathname = path.notrailslash(pathname)
  local i = string.find(string.reverse(pathname), "/") or string.find(string.reverse(pathname), ":")
  if i then
    return string.sub(pathname, -i + 1)
  else
    return pathname
  end
end

function path.dirname(pathname)
  return path.trailslash(path.resolve(pathname, ".."))
end

function path.trailslash(pathname)
  if string.sub(pathname, -1) == "/" then
    return pathname
  elseif string.sub(pathname, -1) == ":" then
    return pathname
  else
    return pathname .. "/"
  end
end

function path.notrailslash(pathname)
  if string.sub(pathname, -1) == "/" then
    return string.sub(pathname, 1, -2)
  else
    return pathname
  end
end

return path
