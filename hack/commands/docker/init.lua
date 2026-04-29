local prune = require("hack.commands.docker.prune")

local M = {}

M.COMMAND_ARRAY = { "docker" }

---Register the command on a parent parser.
---@param p any The parent parser.
function M.register_command(p)
  local parser = p:command("docker d")
    :summary("Perform common actions against docker.")
    :description("")
    :command_target("subcommand")
    :require_command(true)

  parser:flag("--podman", "Act upon podman rather than docker.")

  prune.register_command(parser)
end

---Execute the command.
---@param options table The options provided by the command line parser.
function M.execute(options)
  require("hack.commands.docker." .. options.subcommand).execute(options)
end

return M
