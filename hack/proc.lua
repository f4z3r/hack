local io = require("io")

local log = require("hack.log")

local M = {}

---Run a command and returns its output.
---@param cmd string The command to run.
---@param wdir string? The working directory in which to execute the command, by default the current working directory.
---@param trim boolean? Whether to trim whitespace of the end of the output.
---@return string The output of the command.
---@return number The status code of the command.
function M.run(cmd, wdir, trim)
  local delimiter = "LUA_EXIT_CODE"
  local full_cmd = string.format([[(%s 2>&1; echo "%s$?")]], cmd, delimiter)
  if wdir then
    full_cmd = string.format("cd %s; %s", wdir, full_cmd)
  end

  log:debug("executing command", "command", full_cmd)

  local fh = assert(io.popen(full_cmd, "r"))
  local output = fh:read("*a")
  fh:close()

  local content, exit_code_str = output:match("(.*)" .. delimiter .. "(%d+)")
  local exit_code = 1
  if content and exit_code_str then
    output = content
    exit_code = assert(tonumber(exit_code_str))
  end

  if trim then
    output = output:match("(.-)[%s]*$")
  end

  log:debug("command returned", "exit_code", exit_code, "output", output)

  return output, exit_code
end

return M
