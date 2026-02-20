local string = require("string")

local prompt = require("moonshine.prompt")

local bb = require("hack.bitbucket")
local build = require("hack.commands.bitbucket.build")
local cmd_utils = require("hack.commands.utils")
local log = require("hack.log")

local M = {}

M.COMMAND_ARRAY = { "bitbucket" }

---Register the command on a parent parser.
---@param p any The parent parser.
function M.register_command(p)
  local parser = p:command("bitbucket b")
    :summary("Perform common actions against a BitBucket server.")
    :description("")
    :command_target("subcommand")
    :require_command(true)

  parser:option(
    "-a --address",
    "The BitBucket address to act against.",
    cmd_utils.default_env_var_value(M.COMMAND_ARRAY, "address")
  )
  parser:option(
    "-u --username",
    "The BitBucket username to use.",
    cmd_utils.default_env_var_value(M.COMMAND_ARRAY, "username")
  )
  parser:option("-w --password", "The BitBucket password to use. If not provided, will be prompted.")

  build.register_command(parser)
end

---Execute the command.
---@param options table The options provided by the command line parser.
function M.execute(options)
  log:assert(
    options.address,
    string.format(
      "You must specify an address, either via --address or via the %s environment variable.",
      cmd_utils.env_var_name(M.COMMAND_ARRAY, "address")
    )
  )
  log:assert(
    options.username,
    string.format(
      "You must specify a username, either via --username or via the %s environment variable.",
      cmd_utils.env_var_name(M.COMMAND_ARRAY, "username")
    )
  )
  local password = options.password
  if not password then
    password = prompt.get_pass("Bitbucket password:")
  end
  local server = bb.Server:new(options.address, options.username, password)
  require("hack.commands.bitbucket." .. options.subcommand).execute(server, options)
end

return M
