local cmd_utils = require("hack.commands.utils")
local search = require("hack.commands.jira.search")

local prompt = require("moonshine.prompt")

local M = {}

M.COMMAND_ARRAY = { "jira" }

function M.register_command(p)
  local parser = p:command("jira j")
    :summary("Perform common actions against a Jira.")
    :description("")
    :command_target("subcommand")
    :require_command(false)

  parser:option(
    "-a --address",
    "The Jira address to act against.",
    cmd_utils.default_env_var(M.COMMAND_ARRAY, "address")
  )
  parser:option("-u --username", "The Jira username to use.", cmd_utils.default_env_var(M.COMMAND_ARRAY, "username"))
  parser:option("-w --password", "The Jira password to use. If not provided, will be prompted.")

  search.register_command(parser)
end

function M.execute(options)
  local password = options.password
  if not password then
    password = prompt.get_pass("Jira password:")
  end
  -- local server = bb.Server:new(options.address, options.username, password)
  -- require("hack.commands.jira." .. options.subcommand).execute(server, options)
end

return M
