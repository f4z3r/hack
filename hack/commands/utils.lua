local os = require("os")
local string = require("string")
local table = require("table")

local M = {}

local COMMAND_SEPARATOR = "_"
local BASE_NAME = "hack"

---Returns the name for a variable set within the environment for a command string.
---@param commands string[] The command array under which the variable is applicable.
---@param variable string The variable for which to get the default value.
---@return string
function M.env_var_name(commands, variable)
  local prefix = table.concat(commands, COMMAND_SEPARATOR)
  prefix = BASE_NAME .. COMMAND_SEPARATOR .. prefix .. COMMAND_SEPARATOR .. variable
  return string.upper(prefix)
end

---Returns the default value for a variable set within the environment for a command string.
---@param commands string[] The command array under which the variable is applicable.
---@param variable string The variable for which to get the default value.
---@return string?
function M.default_env_var_value(commands, variable)
  return os.getenv(M.env_var_name(commands, variable))
end

return M
