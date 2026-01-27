local log = require("hack.log")
local string = require("string")

local client = require("hack.http.client")

local M = {}

---Get the repository name based on the remote repository URL.
---@param url string The remote URL.
---@return string?
function M.get_repo_from_url(url)
  return string.match(url, "[^/]+/([^/]+)%.git$")
end

---Get the project name based on the remote repository URL.
---@param url string The remote URL.
---@return string?
function M.get_project_from_url(url)
  return string.match(url, "([^/]+)/[^/]+%.git$")
end

---@enum hack.bitbucket.BuildStatus
local BuildStatus = {
  Failed = "FAILED",
  Successful = "SUCCESSFUL",
  InProgress = "INPROGRESS",
  Cancelled = "CANCELLED",
}

M.BuildStatus = BuildStatus

---@class hack.bitbucket.Server
---@field private client JsonClient
local Server = {}

---Create a new BitBucket server.
---@param address string The address to which to connect.
---@param username string The username to use to connect to the API (basic auth).
---@param password string The password to use to connect to the API (basic auth).
---@return hack.bitbucket.Server
function Server:new(address, username, password)
  local c = client.JsonClient:new()
  c:base_url(address)
  c:basic_auth(username, password)
  local o = { client = c }
  setmetatable(o, self)
  self.__index = self
  return o
end

---Get latest commit from a PR.
---@param project string The project slug.
---@param repo any The repository slug.
---@param pr_id number The PR ID for which to get the commit.
---@return string
function Server:get_latest_commit(project, repo, pr_id)
  -- See: https://developer.atlassian.com/server/bitbucket/rest/v1000/api-group-pull-requests/#api-api-latest-projects-projectkey-repos-repositoryslug-pull-requests-pullrequestid-get
  return self.client
    :get(string.format("rest/api/latest/projects/%s/repos/%s/pull-requests/%d", project, repo, pr_id))
    :go()
    :expect(function(response)
      log:fatal("could not retrieve PR information (%d): %s", response.status, response.content)
    end)
    :json().fromRef.latestCommit
end

---Get build list for a specific commit.
---@param commit string The commit for which to get the build list.
---@return table[]
function Server:get_builds(commit)
  -- See: https://developer.atlassian.com/server/bitbucket/rest/v1000/api-group-builds-and-deployments/#api-build-status-latest-commits-stats-commitid-get
  return self.client
    :get(string.format("rest/build-status/latest/commits/%s", commit))
    :go()
    :expect(function(response)
      log:fatal("could not retrieve builds for commit %s (%d): %s", commit, response.status, response.content)
    end)
    :json().values
end

---Mark a build with a new status. This will overwrite the name of the build to indicate that the status was manually
---overwritten.
---@param project string The project slug.
---@param repo string The repository slug.
---@param commit string The commit which triggered the build.
---@param key string The build key attached to the build on the specific commit.
---@param status hack.bitbucket.BuildStatus The build status to apply to the build.
function Server:mark_build(project, repo, commit, key, status)
  local build = self.client
    :get(string.format("rest/api/latest/projects/%s/repos/%s/commits/%s/builds", project, repo, commit), { key = key })
    :go()
    :expect(function(response)
      log:fatal("could not retrieve build %s for commit %s (%d): %s", key, commit, response.status, response.content)
    end)
    :json()
  -- This is not properly documented on the REST API.
  self.client
    :post(string.format("rest/build-status/1.0/commits/%s", commit), nil, {
      key = key,
      state = status,
      url = build.url,
      name = build.name .. " (manual override by f4z3r)",
      description = build.description,
    })
    :go()
    :expect(function(response)
      log:fatal(
        "could not set build status for build %s on commit %s (%d): %s",
        key,
        commit,
        response.status,
        response.content
      )
    end)
end

M.Server = Server

return M
