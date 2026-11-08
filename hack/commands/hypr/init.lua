local monitors = require("hack.commands.hypr.monitors")

local M = {}

M.COMMAND_ARRAY = { "hypr" }

---Register the command on a parent parser.
---@param p any The parent parser.
function M.register_command(p)
  local parser = p:command("hypr h")
    :summary("change stuff in Hyprland")
    :description("Perform common actions against Hyprland.")
    :command_target("subcommand")
    :require_command(true)

  monitors.register_command(parser)
end

---Execute the command.
---@param options table The options provided by the command line parser.
function M.execute(options)
  require("hack.commands.hypr." .. options.subcommand).execute(options)
end

return M
