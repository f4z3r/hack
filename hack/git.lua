local proc = require("hack.proc")
local strings = require("hack.strings")

local M = {}

---Get the configured remotes of a git repo at dir.
---@param dir string The path to the git repo.
---@return table
function M.get_remotes(dir)
  local tmp = {}
  local out = proc.run("git remote -v", dir, true)
  for _, line in ipairs(strings.lines(out, true)) do
    local name, url, type = unpack(strings.split(line, "%s+"))
    type = type:sub(2, -2) -- trim parentheses
    if tmp[name] then
      tmp[name].types[#tmp[name].types + 1] = type
    else
      tmp[name] = { url = url, types = { type } }
    end
  end
  local res = {}
  for name, remote in pairs(tmp) do
    res[#res + 1] = { name = name, url = remote.url, types = remote.types }
  end
  return res
end

return M
