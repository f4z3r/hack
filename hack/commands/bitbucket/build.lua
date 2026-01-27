local prompt = require("moonshine.prompt")
local string = require("string")
local text = require("luatext")

local bb = require("hack.bitbucket")
local git = require("hack.git")
local log = require("hack.log")

local M = {}

M.COMMAND_ARRAY = { "bitbucket", "build" }

function M.register_command(p)
  local parser = p:command("build b"):summary("Act on builds."):description("")

  parser
    :argument("project/repo", "The project and repo to act upon, by default the repo of the current directory.")
    :args("?")
  parser:mutex(
    parser:option("-p --pr", "ID of the PR from which to pull the latest build."),
    parser:option("-c --commit", "The commit id to act upon.")
  )
  parser:mutex(
    parser:flag("--approve", "Approve the non-successful builds."),
    parser:flag("--cancel", "Cancel the non-successful builds.")
  )
end

---Execute builds command.
---@param server hack.bitbucket.Server The BitBucket server to act upon.
---@param options table Options provided to this command.
function M.execute(server, options)
  local project
  local repo
  if not options["project/repo"] then
    local remotes = git.get_remotes(".")
    log:assert(#remotes ~= 1, "found %d remotes", #remotes)
    project = bb.get_project_from_url(remotes[1].url)
    repo = bb.get_repo_from_url(remotes[1].url)
  else
    project, repo = string.match(options["project/repo"], "^([^/]+)/([^/]+)$")
  end
  log:assert(project, "failed to detect project")
  log:assert(repo, "failed to detect repository")
  local commit = options.commit
  if not commit then
    commit = server:get_latest_commit(project, repo, options.pr)
  end
  log:assert(commit, "You need to provide either --commit or --pr to get a commit on which to check builds.")
  local builds = server:get_builds(commit)

  print(string.format("Found %d build(s) for commit %s:", #builds, commit))
  for _, build in ipairs(builds) do
    local status = text.Text:new(build.state)
    if build.state == bb.BuildStatus.Successful then
      status:fg(text.Color.Green)
    elseif build.state == bb.BuildStatus.Failed then
      status:fg(text.Color.Red)
    else
      status:fg(text.Color.Yellow)
    end
    local id = text.Text:new(build.key):fg(text.Color.Blue)
    print(string.format("- build %s with status %s", id:render(), status:render()))
  end

  if options.approve or options.cancel then
    for _, build in ipairs(builds) do
      if build.state ~= bb.BuildStatus.Successful then
        if
          options.approve
          and prompt.confirm(string.format("Mark build %s as successful", text.Text:new(build.key):fg(text.Color.Blue)))
        then
          server:mark_build(project, repo, commit, build.key, bb.BuildStatus.Successful)
          log:warn("marked build %s as successful", build.key)
        elseif
          options.cancel
          and prompt.confirm(string.format("Mark build %s as cancelled", text.Text:new(build.key):fg(text.Color.Blue)))
        then
          server:mark_build(project, repo, commit, build.key, bb.BuildStatus.Cancelled)
          log:warn("marked build %s as cancelled", build.key)
        end
      end
    end
  end
end

return M
