local basexx = require("basexx")
local json = require("rapidjson")

local http_util = require("http.util")
local request = require("http.request")
local string = require("string")

local log = require("hack.log")

local DEFAULT_TIMEOUT = 10

local function dict_to_query(query)
  local data = {}
  for k, v in pairs(query) do
    data[k] = tostring(v)
  end
  return http_util.dict_to_query(data)
end

local M = {}

---@class Response
---@field status number
---@field content string
local Response = {}

function Response:new(o)
  o = o or { status = 500, content = "" }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Response:expect(func)
  if self.status > 299 then
    func(self)
  end
  return self
end

function Response:json()
  return json.decode(self.content)
end

---@class Request
---@field private req http.request
local Request = {}

---@return Request
function Request:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

---@return Request
function Request:body(o)
  if type(o) == "table" then
    o = json.encode(o)
    self.req.headers:upsert("content-type", "application/json")
  end
  self.req:set_body(o)
  return self
end

---@return Request
function Request:bearer(token)
  self.req.headers:upsert("authorization", "Bearer " .. token)
  return self
end

---@return Request
function Request:basic(username, password)
  local token = basexx.to_base64(string.format("%s:%s", username, password))
  self.req.headers:upsert("authorization", "Basic " .. token)
  return self
end

---@return Request
function Request:header(key, value)
  self.req.headers:upsert(key, value)
  return self
end

---@return Response
function Request:go(timeout)
  timeout = timeout or DEFAULT_TIMEOUT
  log:debug("making %s request to %s", self.req.headers:get(":method"), self.req:to_uri())
  local resp_headers, stream = assert(self.req:go(timeout))
  local status = tonumber(resp_headers:get(":status"))
  local body = stream:get_body_as_string()
  log:debug("received response (%d): %s", status, body)
  return Response:new({ status = status, content = body })
end

---@param url string
---@param query table?
---@return Request
function M.new(url, query)
  if query then
    url = string.format("%s?%s", url, dict_to_query(query))
  end
  local req = request.new_from_uri(url)
  req.headers:upsert("accept", "application/json")
  return Request:new({ req = req })
end

---@param url string
---@param query table?
---@return Request
function M.get(url, query)
  local r = M.new(url, query)
  r:header(":method", "GET")
  return r
end

---@param url string
---@param query table?
---@return Request
function M.post(url, query)
  local r = M.new(url, query)
  r:header(":method", "POST")
  return r
end

---@param url string
---@param query table?
---@return Request
function M.delete(url, query)
  local r = M.new(url, query)
  r:header(":method", "DELETE")
  return r
end

M.Request = Request
M.Response = Response

return M
