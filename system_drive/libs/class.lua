print("Don't use class.lua.. object.lua is much better!")
fs.delete(_DIR .. _FILE)

local Class = {}

function Class:new(super, constructor)
  local class = setmetatable({}, super or {})
  class.__index = class
  if constructor then
    class._new = constructor
    function class:new(...)
      local self = setmetatable({}, self)
      self:_new(...)
      return self
    end
  end
  return class
end
return Class
