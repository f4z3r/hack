local proc = require("hack.proc")
local strings = require("hack.strings")

local M = {}

---Get the configured remotes of a git repo at dir.
---@param dir string The path to the git repo.
---@return table
function M.get_remotes(dir)
  local res = {}
  local out = proc.run("git remote -v", dir, true)
  for _, line in ipairs(strings.lines(out, true)) do
    local name, url, type = unpack(strings.split(line, "%s+"))
    type = type:match("%((.*)%)")
    if res[name] then
      res[name].types[#res[name].types + 1] = type
    else
      res[name] = { url = url, types = { type } }
    end
  end
  return res
end

return M
