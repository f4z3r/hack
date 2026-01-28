local prompt = require("moonshine.prompt")

local cmd_utils = require("hack.commands.utils")
local log = require("hack.log")
local search = require("hack.commands.jira.search")

local M = {}

M.COMMAND_ARRAY = { "jira" }

---Register the command on a parent parser.
---@param p any The parent parser.
function M.register_command(p)
  local parser = p:command("jira j")
    :summary("Perform common actions against a Jira.")
    :description("")
    :command_target("subcommand")
    :require_command(false)

  parser:option(
    "-a --address",
    "The Jira address to act against.",
    cmd_utils.default_env_var_value(M.COMMAND_ARRAY, "address")
  )
  parser:option(
    "-u --username",
    "The Jira username to use.",
    cmd_utils.default_env_var_value(M.COMMAND_ARRAY, "username")
  )
  parser:option("-w --password", "The Jira password to use. If not provided, will be prompted.")

  search.register_command(parser)
end

---Execute the command.
---@param options table The options provided by the command line parser.
function M.execute(options)
  log:assert(
    options.username,
    "You must specify a username, either via --username or via the %s environment variable.",
    cmd_utils.env_var_name(M.COMMAND_ARRAY, "username")
  )
  log:assert(
    options.password,
    "You must specify a password, either via --password or via the %s environment variable.",
    cmd_utils.env_var_name(M.COMMAND_ARRAY, "password")
  )
  local password = options.password
  if not password then
    password = prompt.get_pass("Jira password:")
  end
  -- local server = bb.Server:new(options.address, options.username, password)
  -- require("hack.commands.jira." .. options.subcommand).execute(server, options)
end

return M
