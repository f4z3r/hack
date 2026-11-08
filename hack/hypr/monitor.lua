local json = require("rapidjson")

local log = require("hack.log")
local proc = require("hack.proc")
local utils = require("hack.utils")

local M = {}

---@class hack.hypr.Monitor
---@field id number
---@field name string
---@field resolution hack.utils.Vector
---@field position hack.utils.Vector
---@field scale number
---@field flipped boolean
---@field modes string[]
---@field mirror_of number?
local Monitor = {}

---Create a new monitor.
---@param id number The ID of the monitor.
---@param name string The name of the monitor.
---@param resolution hack.utils.Vector The resolution of the monitor.
---@param position hack.utils.Vector The position of the monitor.
---@param scale number The scaling factor of the monitor.
---@param flipped boolean Whether the monitor is flipped.
---@param modes string[] Modes available on that monitor
---@param mirror_of number? Whether the monitor is a mirror of another.
---@return hack.hypr.Monitor
function Monitor:new(id, name, resolution, position, scale, flipped, modes, mirror_of)
  local o = {
    id = id,
    name = name,
    resolution = resolution,
    position = position,
    scale = scale,
    flipped = flipped,
    modes = modes,
    mirror_of = mirror_of,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

---Create a list of monitors from Hyprctl output.
---@param output string The JSON Hyprctl output.
---@return hack.hypr.Monitor[]
function Monitor:from_hyprctl(output)
  local deserialized = json.decode(output)
  local res = {}
  for _, mon in ipairs(deserialized) do
    local resolution = utils.Vector:new(mon.width, mon.height)
    local position = utils.Vector:new(mon.x, mon.y)
    local mirror_of = tonumber(mon.mirrorOf)
    local flipped = mon.transform % 2 == 1
    res[#res + 1] =
      Monitor:new(mon.id, mon.name, resolution, position, mon.scale, flipped, mon.availableModes, mirror_of)
  end
  return res
end

---Return the mode string of the monitor.
---@return string
function Monitor:mode()
  return self.resolution:to_string("x")
end

---Compute the position this monitor if placed left of another monitor
---@param other hack.hypr.Monitor The other monitor
---@return hack.utils.Vector
function Monitor:left_of(other)
  local width = (self.flipped and self.resolution.y or self.resolution.x) / self.scale
  return other.position:add(-width, 0)
end

---Compute the position this monitor if placed right of another monitor
---@param other hack.hypr.Monitor The other monitor
---@return hack.utils.Vector
function Monitor:right_of(other)
  local width = (other.flipped and other.resolution.y or other.resolution.x) / other.scale
  return other.position:add(width, 0)
end

---Compute the position this monitor if placed above another monitor
---@param other hack.hypr.Monitor The other monitor
---@return hack.utils.Vector
function Monitor:above(other)
  local height = (self.flipped and self.resolution.x or self.resolution.y) / self.scale
  return other.position:add(0, -height)
end

---Compute the position this monitor if placed below another monitor
---@param other hack.hypr.Monitor The other monitor
---@return hack.utils.Vector
function Monitor:below(other)
  local height = (other.flipped and other.resolution.x or other.resolution.y) / other.scale
  return other.position:add(0, height)
end

---Apply some position to the monitor. This will actually move the monitor.
---@param pos hack.utils.Vector The absolute position to which to move the monitor.
function Monitor:apply_position(pos)
  self.position = pos
  local position = string.format("%dx%d", self.position.x, self.position.y)
  local _, status =
    proc.run(string.format([[hyprctl eval 'hl.monitor({ output = "%s", position = "%s"})']], self.name, position))
  log:assert(
    status == 0,
    "failed to set position of monitor",
    "status",
    status,
    "position",
    position,
    "monitor",
    self.name
  )
end

---Apply some scale to the monitor.
---@param scale number The scaling to apply.
function Monitor:apply_scale(scale)
  self.scale = scale
  local _, status = proc.run(
    string.format(
      [[hyprctl eval 'hl.monitor({ output = "%s", scale = "%f", mode = "%s"})']],
      self.name,
      scale,
      self:mode()
    )
  )
  log:assert(status == 0, "failed to set scale of monitor", "status", status, "scale", scale, "monitor", self.name)
end

---Mirror another display.
---@param other string The name of the other monitor to mirror.
function Monitor:mirror(other)
  local _, status = proc.run(
    string.format(
      [[hyprctl eval 'hl.monitor({ output = "%s", mirror = "%s", mode = "%s"})']],
      self.name,
      other,
      self:mode()
    )
  )
  log:assert(status == 0, "failed to mirror monitor", "status", status, "other", other, "monitor", self.name)
end

---Apply some padding for windows of the monitor.
---@param value number The padding to apply
function Monitor:apply_padding(value)
  local _, status = proc.run(
    string.format(
      [[hyprctl eval 'hl.monitor({ output = "%s", reserved_area = "%d", mode = "%s"})']],
      self.name,
      value,
      self:mode()
    )
  )
  log:assert(status == 0, "failed to set padding of monitor", "status", status, "padding", value, "monitor", self.name)
end

---Apply some scale to the monitor.
---@param mode string The mode string such as 1920x1080
function Monitor:apply_mode(mode)
  local x, y = string.match(mode, "^(%d+)x(%d+)$")
  log:assert(x and y, "failed to retrieve resolution width from mode", "mode", mode)
  self.resolution.x = assert(tonumber(x))
  self.resolution.y = assert(tonumber(y))
  local _, status =
    proc.run(string.format([[hyprctl eval 'hl.monitor({ output = "%s", mode = "%s"})']], self.name, mode))
  log:assert(status == 0, "failed to apply mode of monitor", "status", status, "mode", mode, "monitor", self.name)
end

M.Monitor = Monitor

return M
