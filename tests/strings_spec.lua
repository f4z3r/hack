--# selene: allow(undefined_variable, incorrect_standard_library_use)

local strings = require("hack.strings")

context("String", function()
  describe("split", function()
    it("returns the initial string when the separator is not in the original string", function()
      local str = "bbaaccaabb"
      local sep = "yy"
      local res = strings.split(str, sep)
      assert.are.same({ str }, res)
    end)

    it("returns a list of substrings when provided a separator contained in the original string", function()
      local str = "bbaaccaabb"
      local sep = "aa"
      local res = strings.split(str, sep)
      assert.are.same({ "bb", "cc", "bb" }, res)
    end)

    it("returns the correct number of lines when splitting by newlines", function()
      local str = "test\nthis\n\nyes"
      local res = strings.lines(str)
      assert.are.equal(4, #res)
    end)
  end)
end)
