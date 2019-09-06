function _init(args)
  local src = args[1]
  local dest = args[#args]
  if fs.isdir(dest) then
    dest = trailslash(dest)
    for i = 1, #args - 1 do
      local entry = args[i]
      if fs.isdir(entry) then
        if not copydir(entry, dest .. entry) then
          return sys.exit(1)
        end
      else
        if not copyfile(entry, dest .. entry) then
          return sys.exit(1)
        end
      end
    end
  else
    if not copyfile(src, dest) then
      return sys.exit(1)
    end
  end
end

function copyfile(src, dest)
  local data = fs.read(src)
  if not data then
    print("Could not read '" .. src .. "'!")
    return false
  end
  if not fs.write(dest, data) then
    print("Could not write to '" .. dest .. "'!")
    return false
  end
  return true
end

function copydir(src, dest)
  src = trailslash(src)
  dest = trailslash(dest)
  if not fs.mkdir(dest) then
    print("Could not create dir '" .. dest .. "'!")
    return false
  end
  local entries = fs.list(src)
  for i, entry in pairs(entries) do
    if fs.isdir(src .. entry) then
      if not copydir(src .. entry, dest .. entry) then
        return false
      end
    else
      if not copyfile(src .. entry, dest .. entry) then
        return false
      end
    end
  end
  return true
end

function basename(path)
  local i = string.find(string.reverse(path), "/") - 1
  return string.sub(path, -i)
end

function trailslash(path)
  if string.sub(path, -1) == "/" then
    return path
  else
    return path .. "/"
  end
end
