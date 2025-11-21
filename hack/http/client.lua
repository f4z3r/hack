local http = require("hack.http")
local log = require("hack.log")

local M = {}

---@class JsonClient
local JsonClient = {}

function JsonClient:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function JsonClient:base_url(url)
  self.baseurl = url
  return self
end

function JsonClient:basic_auth(username, password)
  self.username = username
  self.password = password
  return self
end

function JsonClient:get(path, query)
  local url = string.format("%s/%s", self.baseurl, path)
  local req = http.get(url, query)
  if self.username then
    log:assert(self.password, "cannot use basic auth with only username and no password")
    req:basic(self.username, self.password)
  end
  return req
end

function JsonClient:post(path, query, body)
  local url = string.format("%s/%s", self.baseurl, path)
  local req = http.post(url, query)
  if self.username then
    log:assert(self.password, "cannot use basic auth with only username and no password")
    req:basic(self.username, self.password)
  end
  req:body(body)
  return req
end

M.JsonClient = JsonClient

return M
