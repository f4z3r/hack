local prompt = require("moonshine.prompt")

local bb = require("hack.bitbucket")
local build = require("hack.commands.bitbucket.build")
local cmd_utils = require("hack.commands.utils")

local M = {}

M.COMMAND_ARRAY = { "bitbucket" }

function M.register_command(p)
  local parser = p:command("bitbucket b")
    :summary("Perform common actions against a BitBucket server.")
    :description("")
    :command_target("subcommand")
    :require_command(false)

  parser:option(
    "-a --address",
    "The BitBucket address to act against.",
    cmd_utils.default_env_var(M.COMMAND_ARRAY, "address")
  )
  parser:option(
    "-u --username",
    "The BitBucket username to use.",
    cmd_utils.default_env_var(M.COMMAND_ARRAY, "username")
  )
  parser:option("-w --password", "The BitBucket password to use. If not provided, will be prompted.")

  build.register_command(parser)
end

function M.execute(options)
  local password = options.password
  if not password then
    password = prompt.get_pass("Bitbucket password:")
  end
  local server = bb.Server:new(options.address, options.username, password)
  require("hack.commands.bitbucket." .. options.subcommand).execute(server, options)
end

return M
