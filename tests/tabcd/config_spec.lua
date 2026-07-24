local config = require("tabcd.config")

describe("tabcd.config", function()
  before_each(function()
    config.setup({}) -- reset to defaults
  end)

  it("has sane defaults", function()
    assert.equals(2, config.options.depth)
    assert.is_nil(config.options.picker)
    assert.is_false(config.options.hidden)
    assert.is_false(config.options.include_root)
  end)

  it("setup() merges user options over defaults", function()
    config.setup({ depth = 5, picker = "fzf" })
    assert.equals(5, config.options.depth)
    assert.equals("fzf", config.options.picker)
    assert.is_false(config.options.hidden) -- untouched default survives the merge
  end)

  it("resolve() overrides config for a single call without mutating it", function()
    config.setup({ depth = 2 })
    local resolved = config.resolve({ depth = 9 })
    assert.equals(9, resolved.depth)
    assert.equals(2, config.options.depth)
  end)

  it("resolve() returns the base config when no per-call opts are given", function()
    config.setup({ depth = 4 })
    assert.equals(4, config.resolve(nil).depth)
  end)
end)
