local package_version = "0.1.0"
local rockspec_revision = "0"

rockspec_format = "3.0"
package = "hack"
version = package_version .. "-" .. rockspec_revision
source = {
  url = "git://github.com/f4z3r/hack.git",
  tag = "v" .. package_version,
}
description = {
  summary = "A library to make CLIs beautiful.",
  detailed = [[
     TODO
   ]],
  homepage = "https://github.com/f4z3r/hack/tree/main",
  license = "MIT",
}
dependencies = {
  "lua >= 5.1, < 5.4",
  "lanes >= 3.16",
  "luaposix >= 34",
}
test_dependencies = {
  "busted >= 2.2",
  "luatext >= 1.2",
}
test = {
  type = "busted",
}
build = {
  type = "builtin",
  modules = {
  },
}

