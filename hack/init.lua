local log = require("hack.log")

local M = {}

M.VERSION = "0.2.0"

function M.main()
  local commands = require("hack.commands")
  local options, parser = commands.parse()
  if options.version then
    print("hack version v" .. M.VERSION)
    return
  end

  if options.verbosity >= 2 then
    log:set_level(log.LogLevel.DEBUG)
  elseif options.verbosity == 1 then
    log:set_level(log.LogLevel.INFO)
  elseif options.quiet then
    log:set_level(log.LogLevel.ERROR)
  else
    log:set_level(log.LogLevel.WARN)
  end

  if options.json then
    log:json()
  end

  local cmd = options.command
  if not cmd then
    print(parser:get_usage())
    return
  end
  require("hack.commands." .. cmd).execute(options)
end

return M
