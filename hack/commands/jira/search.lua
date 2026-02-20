local string = require("string")
local text = require("luatext")

local log = require("hack.log")

local M = {}

M.COMMAND_ARRAY = { "jira", "search" }

---Register the command on a parent parser.
---@param p any The parent parser.
function M.register_command(p)
  local parser = p:command("search s"):summary("Search issues"):description("Search issues based on a provided term.")

  parser:argument("term", "The term to search for.")
  parser:argument("project", "The project(s) to search."):args("+")
  parser:flag("-c --closed", "Include closed issues in the search.")
  parser:flag("-i --ids", "Just output the list of IDs.")
  parser:flag("-d --description", "Also search within the description.")
end

---Execute search command.
---@param server hack.jira.Server The Jira server to act upon.
---@param options table Options provided to this command.
function M.execute(server, options)
  local query_parts = {
    string.format("project in (%s)", table.concat(options.project, ", ")),
  }
  local term_query = string.format('summary ~ "%s"', options.term)
  if options.description then
    term_query = string.format('(%s OR description ~ "%s")', term_query, options.term)
  end
  query_parts[#query_parts + 1] = term_query
  if not options.closed then
    query_parts[#query_parts + 1] = "status not in (Cancelled, Done)"
  end
  local jql = table.concat(query_parts, " AND ") .. " ORDER BY priority DESC, updated DESC"
  log:info("final jql query", "jql", jql)
  local issues = server:get_tickets(jql, { "key", "summary" })
  if options.ids then
    for _, issue in ipairs(issues) do
      print(issue.key)
    end
    return
  end
  print(string.format("%-13s %s", "Key", "Title"))
  for _, issue in ipairs(issues) do
    local buffer = string.rep(" ", 13 - #issue.key)
    print(
      string.format("%s%s %s", text.Text:new(issue.key):fg(text.Color.Magenta):render(), buffer, issue.fields.summary)
    )
  end
end

return M
