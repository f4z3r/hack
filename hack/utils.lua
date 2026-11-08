local string = require("string")

local M = {}

function M.deep_copy(obj, seen)
  if type(obj) ~= "table" then
    return obj
  end
  if seen and seen[obj] then
    return seen[obj]
  end

  local s = seen or {}
  local res = {}
  s[obj] = res
  for k, v in pairs(obj) do
    res[M.deep_copy(k, s)] = M.deep_copy(v, s)
  end
  return setmetatable(res, getmetatable(obj))
end

---@class hack.utils.Vector
---@field x number
---@field y number
local Vector = {}

---Create a new vector.
---@param x number
---@param y number
---@return hack.utils.Vector
function Vector:new(x, y)
  local o = { x = x, y = y }
  setmetatable(o, self)
  self.__index = self
  return o
end

---Unpack a vector into its x and y coordinates.
---@return number The x coordinate
---@return number The y coordinate
function Vector:unpack()
  return self.x, self.y
end

---Create a new vector that adds the coordinates.
---@param x number
---@param y number
---@return hack.utils.Vector
function Vector:add(x, y)
  return Vector:new(self.x + x, self.y + y)
end

---Create a new vector that adds the coordinates.
---@param vec hack.utils.Vector
---@return hack.utils.Vector
function Vector:addv(vec)
  return self:add(vec:unpack())
end

---Negate a vector.
---@return hack.utils.Vector
function Vector:negate()
  return Vector:new(-self.x, -self.y)
end

---Create a new vector that substracts the coordinates.
---@param vec hack.utils.Vector
---@return hack.utils.Vector
function Vector:subv(vec)
  return self:addv(vec:negate())
end

---Create a new vector that substracts the coordinates.
---@param x number
---@param y number
---@return hack.utils.Vector
function Vector:sub(x, y)
  local vec = Vector:new(x, y)
  return self:subv(vec)
end

---Convert to string of the format 100,200.
---@return string
function Vector:to_string(separator)
  separator = separator or ","
  return string.format("%d%s%d", self.x, separator, self.y)
end

M.Vector = Vector

return M
