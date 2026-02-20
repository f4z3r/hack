local argparse = require("argparse")

local bitbucket = require("hack.commands.bitbucket")
local jira = require("hack.commands.jira")

local M = {}

---Parse the command line arguments.
---@return table
---@return any
function M.parse()
  local parser = argparse()
    :name("hack")
    :description("A tool that does all kinds of hacky things...")
    :epilog("See https://github.com/f4z3r/hack for more details.")
    :add_complete()
    :help_max_width(80)
    :command_target("command")
    :require_command(false)

  parser:flag("-V --version", "Print the version of hack.")
  parser:mutex(
    parser:flag("-v --verbose", "Set the verbosity for logging. Can be repeated."):count("0-2"):target("verbosity"),
    parser:flag("-q --quiet", "Only log truly critical errors.")
  )
  parser:flag("--json", "Log in JSON format")

  jira.register_command(parser)
  bitbucket.register_command(parser)

  return parser:parse(), parser
end

return M
