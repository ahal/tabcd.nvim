local label = require("tabcd.label")

describe("tabcd.label", function()
  it("returns the root's basename when path equals root", function()
    assert.equals("repo", label.abbreviate("/home/user/repo", "/home/user/repo"))
  end)

  it("abbreviates parent segments to their first letter, keeping the leaf full", function()
    assert.equals("p/mozversioncontrol", label.abbreviate("/repo", "/repo/python/mozversioncontrol"))
  end)

  it("keeps a single top-level directory intact", function()
    assert.equals("apps", label.abbreviate("/repo", "/repo/apps"))
  end)

  it("abbreviates every intermediate segment for deeply nested paths", function()
    assert.equals("a/b/c/leaf", label.abbreviate("/repo", "/repo/apps/backend/core/leaf"))
  end)

  it("passes through paths outside the root unchanged aside from the leaf rule", function()
    assert.equals("o/other", label.abbreviate("/repo", "/other/other"))
  end)
end)
