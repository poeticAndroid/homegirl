function _init(args)
  local src = args[1]
  local dest = args[#args]
  if fs.isdir(dest) then
  -- todo
  end
  fs.write(dest, fs.read(src))
end

function basename(path)
  -- todo
end
