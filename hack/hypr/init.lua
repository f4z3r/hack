local log = require("hack.log")
local monitor = require("hack.hypr.monitor")
local proc = require("hack.proc")

local M = {}

function M.get_monitors()
  local out, status = proc.run("hyprctl monitors all -j")
  log:assert(status == 0, "failed to get monitors from hyprctl", "status", status)
  local monitors = monitor.Monitor:from_hyprctl(out)
  return monitors
end

return M
