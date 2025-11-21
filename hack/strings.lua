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

return M
