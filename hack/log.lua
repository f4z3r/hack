local io = require("io")
local os = require("os")
local string = require("string")

local text = require("luatext")

local PREFIX = {
  DEBUG = text.Text:new("DEBUG "):fg(text.Color.Magenta):render(),
  INFO = text.Text:new("INFO "):fg(text.Color.Blue):render(),
  WARN = text.Text:new("WARN "):fg(text.Color.Yellow):render(),
  ERROR = text.Text:new("ERROR "):fg(text.Color.Red):render(),
  FATAL = text.Text:new("FATAL "):fg(text.Color.Red):render(),
}

---@class Logger
---@field private filename string
---@field private level LogLevel
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

---Create a new logger. This should typically not be called unless you explicitly want to use a different logger.
---@return Logger
function Logger:new()
  local o = { level = self.LogLevel.WARN }
  setmetatable(o, self)
  self.__index = self
  return o
end

---Log something regardless of log-level.
---@param entry string A format string with potential placeholders.
---@vararg any The values to fill into the placeholders.
function Logger:log(entry, ...)
  io.stderr:write(string.format(entry .. "\n", ...))
end

---Debug log a message.
---@param entry string A format string with potential placeholders.
---@vararg any The values to fill into the placeholders.
function Logger:debug(entry, ...)
  if self.level <= self.LogLevel.DEBUG then
    self:log(PREFIX.DEBUG .. entry, ...)
  end
end

---Info log a message.
---@param entry string A format string with potential placeholders.
---@vararg any The values to fill into the placeholders.
function Logger:info(entry, ...)
  if self.level <= self.LogLevel.INFO then
    self:log(PREFIX.INFO .. entry, ...)
  end
end

---Warn log a message.
---@param entry string A format string with potential placeholders.
---@vararg any The values to fill into the placeholders.
function Logger:warn(entry, ...)
  if self.level <= self.LogLevel.WARN then
    self:log(PREFIX.WARN .. entry, ...)
  end
end

---Error log a message.
---@param entry string A format string with potential placeholders.
---@vararg any The values to fill into the placeholders.
function Logger:error(entry, ...)
  if self.level <= self.LogLevel.ERROR then
    self:log(PREFIX.ERROR .. entry, ...)
  end
end

---Fatal log a message. This will exit even if logging is fully disabled.
---@param entry string A format string with potential placeholders.
---@vararg any The values to fill into the placeholders.
function Logger:fatal(entry, ...)
  if self.level <= self.LogLevel.FATAL then
    self:log(PREFIX.FATAL .. entry, ...)
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

return Logger:new()
