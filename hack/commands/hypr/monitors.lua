local string = require("string")
local table = require("table")

local hypr = require("hack.hypr")
local log = require("hack.log")
local proc = require("hack.proc")
local utils = require("hack.utils")

local M = {}

M.COMMAND_ARRAY = { "hypr", "monitors" }

---Register the command on a parent parser.
---@param p any The parent parser.
function M.register_command(p)
  local parser =
    p:command("monitors m"):summary("Manage monitors"):description("Manage monitors such as moving them, scaling, etc.")

  parser:argument("monitor", "The monitor to act on."):args("?")
  parser:mutex(
    parser:option("--left-of", "Move the monitor to the left of another monitor."),
    parser:option("--right-of", "Move the monitor to the right of another monitor."),
    parser:option("--above", "Move the monitor above another monitor."),
    parser:option("--below", "Move the monitor below another monitor."),
    parser:option("--scale", "Scale the monitor to some value."),
    parser:option("--mode", "Set mode for the monitor."),
    parser:option("--pad", "Set a padding for windows of the monitor."),
    parser:option("--mirror", "Mirror into another monitor, the target monitors resolution is preserved"),
    parser:flag("--center", "Center the screen."),
    parser:flag("--reset", "Reset configuration for monitors."),
    parser:flag("--modes", "Display the modes of the monitor.")
  )
end

local function move(source, target, options)
  local pos
  if options.left_of then
    pos = source:left_of(target)
  elseif options.right_of then
    pos = source:right_of(target)
  elseif options.below then
    pos = source:below(target)
  elseif options.above then
    pos = source:above(target)
  end
  log:info("new computed position", "monitor", source.name, "position", pos:to_string("x"))
  source:apply_position(pos)
end

---Execute monitor command.
---@param options table Options provided to this command.
function M.execute(options)
  local monitors = hypr.get_monitors()
  local source, target
  local target_name = options.left_of or options.right_of or options.above or options.below or options.mirror
  for _, monitor in ipairs(monitors) do
    if monitor.name == options.monitor then
      source = monitor
    elseif monitor.name == target_name then
      target = monitor
    end
  end
  if options.left_of or options.right_of or options.above or options.below then
    log:assert(source, "could not find source monitor", "monitor", options.monitor)
    log:assert(target, "could not find target monitor", "monitor", target_name)
    move(source, target, options)
  elseif options.center then
    log:debug("centering monitor", "monitor", options.monitor)
    log:assert(source, "could not find source monitor", "monitor", options.monitor)
    source:apply_position(utils.Vector:new(0, 0))
  elseif options.scale then
    log:debug("scaling monitor", "monitor", source.name, "scale", options.scale)
    log:assert(source, "could not find source monitor", "monitor", options.monitor)
    local value = tonumber(options.scale)
    log:assert(value, "scaling factor needs to be a number", "scale", options.scale)
    source:apply_scale(value)
  elseif options.pad then
    log:debug("padding windows of monitor", "monitor", source.name, "padding", options.pad)
    log:assert(source, "could not find source monitor", "monitor", options.monitor)
    local value = tonumber(options.pad)
    log:assert(value, "padding needs to be a number", "pad", options.pad)
    source:apply_padding(value)
  elseif options.mode then
    log:debug("setting mode for monitor", "monitor", source.name, "mode", options.mode)
    log:assert(source, "could not find source monitor", "monitor", options.monitor)
    source:apply_mode(options.mode)
  elseif options.modes then
    log:assert(source, "could not find source monitor", "monitor", options.monitor)
    print(table.concat(source.modes, "\n"))
  elseif options.mirror then
    log:debug("setting mirror option for monitor", "monitor", source.name, "other", options.mirror)
    log:assert(source, "could not find source monitor", "monitor", options.monitor)
    log:assert(target, "could not find target monitor", "monitor", options.mirror)
    source:mirror(options.mirror)
  elseif options.reset then
    local _, status = proc.run("hyprctl reload")
    log:assert(status == 0, "failed to reset configuration", "status", status)
  else
    for _, monitor in ipairs(monitors) do
      local out = string.format("%d: %-10s %dx%d", monitor.id, monitor.name, monitor.position.x, monitor.position.y)
      if monitor.mirror_of ~= nil then
        out = out .. string.format(" (mirrors %s)", monitor.mirror_of)
      end
      print(out)
    end
  end
end

return M
