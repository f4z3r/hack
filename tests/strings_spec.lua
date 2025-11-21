--# selene: allow(undefined_variable, incorrect_standard_library_use)

local strings = require("hack.strings")

context("Given we are split strings", function()
  describe("when we provide a string without separators, it", function()
    local sep = "yy"
    local str = "bbaaccaabb"
    local res = strings.split(str, sep)

    it("returns the initial string", function()
      assert.are.same({ str }, res)
    end)
  end)

  describe("when we provide a string with 2 separators, it", function()
    local sep = "aa"
    local str = "bbaaccaabb"
    local res = strings.split(str, sep)

    it("correctly provides the correct 3 values", function()
      assert.are.same({ "bb", "cc", "bb" }, res)
    end)
  end)

  describe("when split by lines, it", function()
    local str = "test\nthis\n\nyes"
    local res = strings.lines(str)

    it("returns the correct number of lines", function()
      assert.are.equal(4, #res)
    end)
  end)
end)
