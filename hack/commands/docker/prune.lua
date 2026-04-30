local string = require("string")

local prompt = require("moonshine.prompt")
local text = require("luatext")

local docker = require("hack.docker")
local log = require("hack.log")

local M = {}

M.COMMAND_ARRAY = { "docker", "prune" }

---Register the command on a parent parser.
---@param p any The parent parser.
function M.register_command(p)
  local parser =
    p:command("prune p"):summary("Prune entities"):description("Prune docker entities based on some attributes.")

  parser:argument("type", "Type of entity to prune."):choices({ "image", "container" }):default("image")
  parser:flag("-f --force", "Force the pruning rather than always ask.")
  parser:option("--older", "Filter entities that are older than a specific date.")
  -- parser:option("--size", "Filter images that are larger than...")
end

local function prune_images(client, options)
  local images = client:get_images()
  if options.older then
    local filtered = {}
    for _, image in ipairs(images) do
      if image:is_older_than(options.older) then
        filtered[#filtered + 1] = image
      end
    end
    images = filtered
  end
  for _, image in ipairs(images) do
    if
      options.force
      or prompt.confirm(
        string.format("Prune image %s@%s", text.Text:new(image:fullname()):fg(text.Color.Blue), image.digest)
      )
    then
      client:delete_image(image)
      log:warn("pruned image from system", "id", image.id)
    end
  end
end

---Execute prune command.
---@param options table Options provided to this command.
function M.execute(options)
  local client = docker.DockerClient:new()
  if options.podman then
    client = docker.PodmanClient:new()
  end
  if options.type == "image" then
    prune_images(client, options)
  elseif options.type == "container" then
    log:fatal("container entity type is not yet implemented")
  end
end

return M
