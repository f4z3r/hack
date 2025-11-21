local os = require("os")
local string = require("string")
local table = require("table")

local M = {}

local COMMAND_SEPARATOR = "_"
local BASE_NAME = "hack"

---Returns the default value for a variable set within the environment for a command string.
---@param commands string[] The command array under which the variable is applicable.
---@param variable string The variable for which to get the default value.
---@return string?
function M.default_env_var(commands, variable)
  local prefix = table.concat(commands, COMMAND_SEPARATOR)
  prefix = BASE_NAME .. COMMAND_SEPARATOR .. prefix .. COMMAND_SEPARATOR .. variable
  return os.getenv(string.upper(prefix))
end

return M
