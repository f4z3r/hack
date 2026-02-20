local log = require("hack.log")

local client = require("hack.http.client")

local M = {}

---@class hack.jira.Server
---@field private client JsonClient
local Server = {}

---Create a new Jira server.
---@param address string The address to which to connect.
---@param username string The username to use to connect to the API (basic auth).
---@param password string The password to use to connect to the API (basic auth).
---@return hack.jira.Server
function Server:new(address, username, password)
  local c = client.JsonClient:new()
  c:base_url(address)
  c:basic_auth(username, password)
  local o = { client = c }
  setmetatable(o, self)
  self.__index = self
  return o
end

---Search for tickets based on a JQL query.
---@param jql_query string The query according to which to search.
---@param fields string[]? The fields to provide on the issues.
---@return table[]
function Server:get_tickets(jql_query, fields)
  return self.client
    :post("rest/api/2/search", nil, {
      jql = jql_query,
      fields = fields,
    })
    :go()
    :expect(function(response)
      log:fatal("could not get issues for query", "jql", jql_query, "status", response.status, "body", response.content)
    end)
    :json().issues
end

M.Server = Server

return M
