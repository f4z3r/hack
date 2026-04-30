local json = require("rapidjson")

local img = require("hack.docker.image")
local log = require("hack.log")
local proc = require("hack.proc")
local strings = require("hack.strings")

local M = {}

---@class hack.docker.Client
local Client = {}

function Client:new()
  log:fatal("Client:new is not implemented by subclass")
end

---Get all images
---@return hack.docker.Image[]
function Client:get_images()
  log:fatal("Client:get_images is not implemented by subclass")
end

---Delete an image
---@param image hack.docker.Image The image to delete.
function Client:delete_image(image)
  log:fatal("Client:delete_image is not implemented by subclass")
end

---@class hack.docker.DockerClient: hack.docker.Client
---@field private cmd string
local DockerClient = {}

---Create a new docker Client.
---@return hack.docker.Client
function DockerClient:new()
  local o = { cmd = "docker" }
  setmetatable(o, self)
  self.__index = self
  return o
end

---Get all images
---@return hack.docker.Image[]
function DockerClient:get_images()
  local cmd = { self.cmd, "image", "list", "-a", "--digests", "--format", "json" }
  local images = {}
  local out, status = proc.run(cmd)
  log:assert(status, "failed to retrieve docker images", "output", out)
  for _, line in ipairs(strings.lines(out, true)) do
    images[#images + 1] = img.Image:new_from_docker_json(line)
  end
  return images
end

---Delete an image
---@param image hack.docker.Image The image to delete.
function DockerClient:delete_image(image)
  local cmd = { self.cmd, "rmi", image.id, "-f" }
  local out, status = proc.run(cmd)
  log:assert(status, "image deletion failed", "output", out)
end

---@class hack.docker.PodmanClient: hack.docker.Client
---@field private cmd string
local PodmanClient = {}

---Create a new podman Client.
---@return hack.docker.Client
function PodmanClient:new()
  local o = { cmd = "podman" }
  setmetatable(o, self)
  self.__index = self
  return o
end

---Get all images
---@return hack.docker.Image[]
function PodmanClient:get_images()
  local cmd = { self.cmd, "images", "-a", "--format", "json" }
  local images = {}
  local out, status = proc.run(cmd)
  log:assert(status, "failed to retrieve podman images", "output", out)
  for _, line in ipairs(json.decode(out)) do
    images[#images + 1] = img.Image:new_from_podman_json(json.encode(line))
  end
  return images
end

---Delete an image
---@param image hack.docker.Image The image to delete.
function PodmanClient:delete_image(image)
  local cmd = { self.cmd, "rmi", image.id, "-f" }
  local out, status = proc.run(cmd)
  log:assert(status, "image deletion failed", "output", out)
end

M.Client = Client
M.PodmanClient = PodmanClient
M.DockerClient = DockerClient

return M
