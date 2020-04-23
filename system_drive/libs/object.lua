local Object = {}
do
  Object.__index = Object
  function Object:constructor()
  end
  function Object:new(...)
    local obj = setmetatable({}, self)
    obj:constructor(...)
    return obj
  end
  function Object:extend()
    local class = setmetatable({}, self)
    class.__index = class
    return class
  end
end
return Object
