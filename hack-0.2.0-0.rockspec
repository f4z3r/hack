local package_version = "0.2.0"
local rockspec_revision = "0"

rockspec_format = "3.0"
package = "hack"
version = package_version .. "-" .. rockspec_revision
source = {
  url = "git://github.com/f4z3r/hack.git",
  tag = "v" .. package_version,
}
description = {
  summary = "A tool that does all kinds of hacky things...",
  detailed = [[
     This is a tool that I personally use to automate tasks I find boring,
     repetitive, or outright just need some automation for whatever reason.
     It does not attempt to be useful to anyone but myself.
     Sorry - not sorry...
   ]],
  homepage = "https://github.com/f4z3r/hack/tree/main",
  license = "MIT",
}
dependencies = {
  "lua >= 5.1, < 5.4",
  "basexx >= 0.4",
  "lua-path >= 0.3",
  "argparse >= 0.7",
  "moonshine >= 0.1",
  "http >= 0.4",
  "rapidjson >= 0.7",
  "luatext >= 1.2",
  "date >= 2.0",
}
test_dependencies = {
  "busted >= 2.2",
}
test = {
  type = "busted",
}
build = {
  type = "builtin",
  modules = {
    ["hack.bitbucket"] = "hack/bitbucket/init.lua",
    ["hack.commands"] = "hack/commands/init.lua",
    ["hack.commands.utils"] = "hack/commands/utils.lua",
    ["hack.commands.bitbucket"] = "hack/commands/bitbucket/init.lua",
    ["hack.commands.bitbucket.build"] = "hack/commands/bitbucket/build.lua",
    ["hack.commands.jira"] = "hack/commands/jira/init.lua",
    ["hack.commands.jira.search"] = "hack/commands/jira/search.lua",
    ["hack.commands.docker"] = "hack/commands/docker/init.lua",
    ["hack.commands.docker.prune"] = "hack/commands/docker/prune.lua",
    ["hack.http"] = "hack/http/init.lua",
    ["hack.http.client"] = "hack/http/client.lua",
    ["hack.jira"] = "hack/jira/init.lua",
    ["hack.docker"] = "hack/docker/init.lua",
    ["hack.docker.image"] = "hack/docker/image.lua",
    ["hack.fs"] = "hack/fs.lua",
    ["hack.git"] = "hack/git.lua",
    ["hack"] = "hack/init.lua",
    ["hack.log"] = "hack/log.lua",
    ["hack.proc"] = "hack/proc.lua",
    ["hack.strings"] = "hack/strings.lua",
    ["hack.utils"] = "hack/utils.lua",
  },
  install = {
    bin = {
      ["hack"] = "bin/hack",
    },
  },
}
