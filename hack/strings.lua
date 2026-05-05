local M = {}

---Split a string.
---@param str string The string to split.
---@param sep string? The pattern on which to split. By default on whitespace.
---@return table
function M.split(str, sep)
  sep = sep or "%s"
  local result = {}
  local from = 1
  local delim_from, delim_to = str:find(sep, from)
  while delim_from do
    table.insert(result, str:sub(from, delim_from - 1))
    from = delim_to + 1
    delim_from, delim_to = str:find(sep, from)
  end
  table.insert(result, str:sub(from))
  return result
end

---Split a string into lines.
---@param str string The string to split.
---@param discard_empty boolean? Whether to discard empty lines.
---@return table
function M.lines(str, discard_empty)
  local res = M.split(str, "\n")
  if discard_empty then
    for idx, line in ipairs(res) do
      if line == "" then
        res[idx] = nil
      end
    end
  end
  return res
end

---Checks whether the input string is a UUID. The UUID version is not enforced.
---@param str string The input string to check.
---@return boolean
function M.is_uuid(str)
  local uuid_len = 36
  if string.len(str) ~= uuid_len then
    return false
  end
  local hex = "%x"
  local group_of_4 = string.rep(hex, 4)
  local group_of_8 = string.rep(hex, 8)
  local group_of_12 = string.rep(hex, 12)
  local pattern = string.format("%s%%-%s%%-%s%%-%s%%-%s", group_of_8, group_of_4, group_of_4, group_of_4, group_of_12)
  return string.find(str, pattern) == 1
end

return M
