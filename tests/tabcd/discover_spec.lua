local discover = require("tabcd.discover")

-- Force the native vim.fs.dir fallback so results don't depend on whether
-- `fd` happens to be installed on the machine running the tests.
local function opts(overrides)
  return vim.tbl_extend("force", {
    depth = 2,
    hidden = false,
    include_root = false,
    fd = { cmd = "definitely-not-a-real-binary" },
  }, overrides or {})
end

describe("tabcd.discover", function()
  local root

  before_each(function()
    root = vim.fn.tempname()
    vim.fn.mkdir(root .. "/apps/web", "p")
    vim.fn.mkdir(root .. "/apps/mobile", "p")
    vim.fn.mkdir(root .. "/packages/core/internal", "p")
    vim.fn.mkdir(root .. "/.hidden", "p")
  end)

  after_each(function()
    vim.fn.delete(root, "rf")
  end)

  it("lists top-level directories at depth 1", function()
    local results = discover.discover(root, opts({ depth = 1 }))
    table.sort(results)
    assert.same({ "apps", "packages" }, results)
  end)

  it("includes nested directories at depth 2", function()
    local results = discover.discover(root, opts({ depth = 2 }))
    table.sort(results)
    assert.same({ "apps", "apps/mobile", "apps/web", "packages", "packages/core" }, results)
  end)

  it("includes deeper directories at depth 3", function()
    local results = discover.discover(root, opts({ depth = 3 }))
    assert.is_true(vim.tbl_contains(results, "packages/core/internal"))
  end)

  it("excludes hidden directories by default", function()
    local results = discover.discover(root, opts({ depth = 1 }))
    assert.is_false(vim.tbl_contains(results, ".hidden"))
  end)

  it("includes hidden directories when hidden = true", function()
    local results = discover.discover(root, opts({ depth = 1, hidden = true }))
    assert.is_true(vim.tbl_contains(results, ".hidden"))
  end)

  it("prepends '.' when include_root = true", function()
    local results = discover.discover(root, opts({ depth = 1, include_root = true }))
    assert.equals(".", results[1])
  end)

  it("find_fd_cmd returns nil for an unresolvable binary", function()
    assert.is_nil(discover.find_fd_cmd("definitely-not-a-real-binary"))
  end)
end)
