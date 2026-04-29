local string = require("string")

local date = require("date")
local json = require("rapidjson")

local log = require("hack.log")

local M = {}

---@class hack.docker.Image
---@field private _id string
---@field private created any
---@field private repository string
---@field private tag string
local Image = {}

--- Parse a docker provided date to a Lua date.
local function parse_docker_date(str)
  if str:sub(-4) == "CEST" then
    str = str:sub(1, -5)
  elseif str:sub(-3) == "CET" then
    str = str:sub(1, -4)
  end
  return date(str)
end

---Create a new Image from docker JSON output.
---@param source string The source JSON string from docker.
---@return hack.docker.Image
function Image:new_from_docker_json(source)
  local deserialised = json.decode(source)
  local created = parse_docker_date(deserialised.CreatedAt)
  local o = {
    _id = deserialised.ID,
    created = created,
    repository = deserialised.Repository,
    tag = deserialised.Tag,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

--- Parse a repository and tag from podman names.
local function parse_podman_repo_and_tag(names)
  for _, name in ipairs(names) do
    if name:find("@") == nil then
      local colon_idx = name:find(":")
      return name:sub(1, colon_idx - 1), name:sub(colon_idx + 1)
    end
  end
end

---Create a new Image from podman JSON output.
---@param source string The source JSON string from podman.
---@return hack.docker.Image
function Image:new_from_podman_json(source)
  local deserialised = json.decode(source)
  local created = date(deserialised.CreatedAt)
  local repo, tag = parse_podman_repo_and_tag(deserialised.Names)
  log:assert(repo, "failed to parse image repository and tag from podman image names")
  local o = {
    _id = deserialised.Id,
    created = created,
    repository = repo,
    tag = tag,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

---Return the ID of the image.
---@return string
function Image:identity()
  return self._id
end

---Return the ID of the image.
---@return string
function Image:fullname()
  return string.format("%s:%s", self.repository, self.tag)
end

---Return the ID of the image.
---@return string
function Image:created_at()
  return self.created:fmt("%F")
end

---Return if the image is older than a date.
---@param str string The string YYYY-MM-DD date against which to check.
---@return boolean
function Image:is_older_than(str)
  local since = date(str)
  return self.created < since
end

M.Image = Image

return M
