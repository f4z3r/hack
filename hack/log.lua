local io = require("io")
local os = require("os")
local string = require("string")
local table = require("table")

local json = require("rapidjson")
local text = require("luatext")

--- @param ... any
--- @return table<string, any>
local function to_args(...)
  local count = select("#", ...)
  local out = {}
  assert(count % 2 == 0, "you cannot call logging with an odd number of args. e.g: msg, [k, v]...")
  for i = 1, count, 2 do
    local key = select(i, ...)
    local value = select(i + 1, ...)
    assert(type(key) == "string", "keys in logging must be strings")
    assert(out[key] == nil, "key collision in logs: " .. key)
    out[key] = value
  end
  return out
end

---@class Logger
---@field private filename string
---@field private level LogLevel
---@field private sink LoggerSink
local Logger = {}

---@enum LogLevel
Logger.LogLevel = {
  DEBUG = 1,
  INFO = 2,
  WARN = 3,
  ERROR = 4,
  FATAL = 5,
  OFF = 99,
}

local levelToString = {
  [Logger.LogLevel.DEBUG] = "debug",
  [Logger.LogLevel.INFO] = "info",
  [Logger.LogLevel.WARN] = "warn",
  [Logger.LogLevel.ERROR] = "error",
  [Logger.LogLevel.FATAL] = "fatal",
}

local STANDARD_SINK_PREFIX = {
  [Logger.LogLevel.DEBUG] = text.Text:new("DEBUG "):fg(text.Color.Magenta):render(),
  [Logger.LogLevel.INFO] = text.Text:new("INFO "):fg(text.Color.Blue):render(),
  [Logger.LogLevel.WARN] = text.Text:new("WARN "):fg(text.Color.Yellow):render(),
  [Logger.LogLevel.ERROR] = text.Text:new("ERROR "):fg(text.Color.Red):render(),
  [Logger.LogLevel.FATAL] = text.Text:new("FATAL "):fg(text.Color.Red):render(),
}

--- @class LoggerSink
--- @field write_line fun(LoggerSink, LogLevel, string, table): nil

--- @class StandardSink : LoggerSink
local StandardSink = {}

---Create a new standard sink. This writes log messages of the form:
---
---@return StandardSink
function StandardSink:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

---@param level LogLevel The level that is being logged.
---@param entry string A format string with potential placeholders.
---@param args table<string, any> Additional arguments to log.
function StandardSink:write_line(level, entry, args)
  local line = STANDARD_SINK_PREFIX[level] .. entry
  local arguments = {}
  for k, v in pairs(args) do
    arguments[#arguments + 1] = string.format("[%s=%s]", k, v)
  end
  line = line .. " " .. table.concat(arguments, " ")
  io.stderr:write(line .. "\n")
end

--- @class JSONSink : LoggerSink
local JSONSink = {}

---Create a new standard sink. This writes log messages of the form:
---
---@return JSONSink
function JSONSink:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

---@param lvl LogLevel The level that is being logged.
---@param entry string A format string with potential placeholders.
---@param args table<string, any> Additional arguments to log.
function JSONSink:write_line(lvl, entry, args)
  local content = { msg = entry, level = levelToString[lvl] }
  for k, v in pairs(args) do
    content[k] = v
  end
  io.stderr:write(json.encode(content) .. "\n")
end

---Create a new logger. This should typically not be called unless you explicitly want to use a different logger.
---@return Logger
function Logger:new()
  local o = { level = self.LogLevel.WARN, sink = StandardSink:new() }
  setmetatable(o, self)
  self.__index = self
  return o
end

---Log something regardless of log-level.
---@param level LogLevel The level that is being logged.
---@param entry string A format string with potential placeholders.
---@vararg any The values to fill into the placeholders.
function Logger:log(level, entry, ...)
  local args = to_args(...)
  self.sink:write_line(level, entry, args)
end

---Debug log a message.
---@param entry string A format string with potential placeholders.
---@vararg any The values to fill into the placeholders.
function Logger:debug(entry, ...)
  if self.level <= self.LogLevel.DEBUG then
    self:log(self.LogLevel.DEBUG, entry, ...)
  end
end

---Info log a message.
---@param entry string A format string with potential placeholders.
---@vararg any The values to fill into the placeholders.
function Logger:info(entry, ...)
  if self.level <= self.LogLevel.INFO then
    self:log(self.LogLevel.INFO, entry, ...)
  end
end

---Warn log a message.
---@param entry string A format string with potential placeholders.
---@vararg any The values to fill into the placeholders.
function Logger:warn(entry, ...)
  if self.level <= self.LogLevel.WARN then
    self:log(self.LogLevel.WARN, entry, ...)
  end
end

---Error log a message.
---@param entry string A format string with potential placeholders.
---@vararg any The values to fill into the placeholders.
function Logger:error(entry, ...)
  if self.level <= self.LogLevel.ERROR then
    self:log(self.LogLevel.ERROR, entry, ...)
  end
end

---Fatal log a message. This will exit even if logging is fully disabled.
---@param entry string A format string with potential placeholders.
---@vararg any The values to fill into the placeholders.
function Logger:fatal(entry, ...)
  if self.level <= self.LogLevel.FATAL then
    self:log(self.LogLevel.FATAL, entry, ...)
  end
  os.exit(27)
end

---Assert an expression. If the expression evaluates to something negative, fatal log the message. Note the expression
---is not lazily evaluated.
---@param exp any An expression that will be use in boolean context for an assertion.
---@param entry string A format string with potential placeholders.
---@vararg any The values to fill into the placeholders.
function Logger:assert(exp, entry, ...)
  if not exp then
    self:fatal(entry, ...)
  end
end

---Set the log level of the logger.
---@param level LogLevel
function Logger:set_level(level)
  self.level = level
end

---Set to a JSON logger.
function Logger:json()
  self.sink = JSONSink:new()
end

return Logger:new()
