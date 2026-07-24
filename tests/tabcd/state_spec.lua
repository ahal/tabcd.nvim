describe("tabcd.state", function()
  before_each(function()
    package.loaded["tabcd.state"] = nil
  end)

  it("captures the cwd once and keeps returning it after cd", function()
    local state = require("tabcd.state")
    local captured = state.get_root()
    assert.equals(vim.fn.getcwd(), captured)

    vim.cmd("cd ..")
    assert.are_not.equal(captured, vim.fn.getcwd())
    assert.equals(captured, state.get_root())
  end)

  it("get_root() only sets the root once, even across repeated calls", function()
    local state = require("tabcd.state")
    local first = state.get_root()

    vim.cmd("cd ..")
    assert.equals(first, state.get_root())
  end)

  it("set_root() updates the root when called again", function()
    local state = require("tabcd.state")
    local first = state.get_root()

    vim.cmd("cd ..")
    state.set_root()

    assert.are_not.equal(first, state.get_root())
    assert.equals(vim.fn.getcwd(), state.get_root())
  end)
end)
