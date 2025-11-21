local path = require("path")

local M = {}

---Walk up the directory to find the root of the git repository.
---@return string?
function M.get_git_root(dir)
  local p = dir
  local found = false
  repeat
    path.each(path.join(p, ".git"), "f", function()
      found = true
    end, {
      recurse = false,
      skipfiles = true,
      skipdots = false,
    })
    if found then
      return p
    end
    p = path.normalize(path.join(p, ".."))
  until p == "/"
  return nil
end

return M
