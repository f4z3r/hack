local prompt = require("moonshine.prompt")
local string = require("string")
local text = require("luatext")

local log = require("hack.log")

local M = {}

M.COMMAND_ARRAY = { "jira", "search" }

---Register the command on a parent parser.
---@param p any The parent parser.
function M.register_command(p)
  local parser = p:command("search s"):summary("Search issues"):description("")

  parser
    :argument("project", "The project(s) to searchs.")
    :args("+")
  parser:flag("-c --closed", "Include closed issues in the search.")
  parser:flag("-d --description", "Also search within the description.")
end

---Execute search command.
---@param server hack.bitbucket.Server The BitBucket server to act upon.
---@param options table Options provided to this command.
function M.execute(server, options)
end

return M

