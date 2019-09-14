local queue = {}
local indent = ""

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
  sys.stepinterval(0)
end

function _step()
  if #queue == 0 then
    return sys.exit()
  end
  local task = table.remove(queue, 1)
  local src = task.src
  local dest = task.dest
  local indent = task.indent
  if fs.isdir(src) then
    if not fs.mkdir(dest) then
      print("Could not create dir '" .. dest .. "'!")
      return sys.exit(1)
    end
    print(indent .. src .. " -> " .. dest)
  else
    local data = fs.read(src)
    if not data then
      print("Could not read '" .. src .. "'!")
      return sys.exit(1)
    end
    if not fs.write(dest, data) then
      print("Could not write to '" .. dest .. "'!")
      return sys.exit(1)
    end
    print(indent .. basename(src) .. " copied!")
  end
end

function copyfile(src, dest)
  local task = {
    src = src,
    dest = dest,
    indent = indent
  }
  table.insert(queue, task)
  return true
end

function copydir(src, dest)
  src = trailslash(src)
  dest = trailslash(dest)
  local task = {
    src = src,
    dest = dest,
    indent = indent
  }
  table.insert(queue, task)
  indent = indent .. "  "
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
  indent = task.indent
  return true
end

function basename(path)
  local i = string.find(string.reverse(path), "/") or string.find(string.reverse(path), ":") or #path
  return string.sub(path, -i + 1)
end

function trailslash(path)
  if string.sub(path, -1) == "/" then
    return path
  else
    return path .. "/"
  end
end
