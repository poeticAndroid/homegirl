function _init(args)
  if #args < 1 then
    print("Usage: bg <path to program> [args...]")
    return sys.exit(1)
  end
  sys.exec(table.remove(args, 1), args, fs.cd())
end
