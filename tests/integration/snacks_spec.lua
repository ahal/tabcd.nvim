-- Exercises the real snacks.nvim library, not a hand-written stub, since our
-- own assumptions about its internals (e.g. which item field it reads a path
-- from) have been wrong before and a stub would just re-encode that mistake.
describe("tabcd.picker.snacks integration", function()
  local orig_snacks_preload

  before_each(function()
    orig_snacks_preload = package.preload["snacks"]
    package.loaded["snacks"] = nil
    package.loaded["tabcd.picker.snacks"] = nil
  end)

  after_each(function()
    package.preload["snacks"] = orig_snacks_preload
  end)

  it("produces items that snacks.picker.util.path() can resolve", function()
    local captured_items
    package.preload["snacks"] = function()
      return {
        picker = {
          pick = function(o)
            captured_items = o.items
          end,
        },
      }
    end

    local picker = require("tabcd.picker.snacks")
    picker.pick({ { display = "apps", path = "/tmp/fixture/apps" } }, { prompt = "Tabcd> " }, function() end)

    -- Load the real snacks.nvim (not our stub above) to resolve the path,
    -- the same way its default previewer does internally.
    package.preload["snacks"] = nil
    package.loaded["snacks"] = nil
    require("snacks") -- populates the `svim` global that picker.util depends on
    local util = require("snacks.picker.util")

    assert.equals("/tmp/fixture/apps", util.path(captured_items[1]))
  end)
end)
