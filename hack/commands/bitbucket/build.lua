local prompt = require("moonshine.prompt")
local string = require("string")
local text = require("luatext")

local bb = require("hack.bitbucket")
local git = require("hack.git")
local log = require("hack.log")

local M = {}

M.COMMAND_ARRAY = { "bitbucket", "build" }

---Register the command on a parent parser.
---@param p any The parent parser.
function M.register_command(p)
  local parser = p:command("build b"):summary("List or modify builds."):description(
    "Retrieve or change build stati for pull requests or specific commits of any repository you have access to."
  )

  parser:argument("pr/commit", "The PR ID or commit hash on which to act.")
  parser:option("-r --repository", "The project and repo to act upon, by default the repo of the current directory.")
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
  if not options.repository then
    local remotes = git.get_remotes(".")
    log:assert(#remotes == 1, "found %d remotes", #remotes)
    project = bb.get_project_from_url(remotes[1].url)
    log:info("got project from remote %s", project)
    repo = bb.get_repo_from_url(remotes[1].url)
    log:info("got repository from remote %s", repo)
  else
    project, repo = string.match(options.repository, "^([^/]+)/([^/]+)$")
  end
  log:assert(project, "failed to detect project")
  log:assert(repo, "failed to detect repository")
  local commit = options["pr/commit"]
  if string.match(commit, "^%d%d?%d?%d?%d?$") then
    local pr_id = assert(tonumber(commit))
    log:info("using PR with id %d", pr_id)
    commit = server:get_latest_commit(project, repo, pr_id)
    log:info("retrieved latest commit %s", commit)
  end
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
