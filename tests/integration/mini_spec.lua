-- Exercises the real mini.pick library, not a hand-written stub, since our
-- own assumptions about its internals (e.g. which item field it reads a path
-- from) have been wrong before and a stub would just re-encode that mistake.
describe("tabcd.picker.mini integration", function()
  local orig_mini_preload

  before_each(function()
    orig_mini_preload = package.preload["mini.pick"]
    package.loaded["mini.pick"] = nil
    package.loaded["tabcd.picker.mini"] = nil
  end)

  after_each(function()
    package.preload["mini.pick"] = orig_mini_preload
  end)

  it("produces items whose `path` field mini.pick's default preview can resolve as a directory", function()
    local captured_items
    package.preload["mini.pick"] = function()
      return {
        start = function(o)
          captured_items = o.source.items
        end,
      }
    end

    local picker = require("tabcd.picker.mini")
    local dir = vim.fn.getcwd() .. "/lua/tabcd/picker"
    picker.pick({ { display = "picker", path = dir } }, { prompt = "Tabcd> " }, function() end)

    -- Load the real mini.pick (not our stub above) to resolve the preview,
    -- the same way `MiniPick.start` does internally.
    package.preload["mini.pick"] = nil
    package.loaded["mini.pick"] = nil
    local MiniPick = require("mini.pick")

    local buf_id = vim.api.nvim_create_buf(false, true)
    MiniPick.default_preview(buf_id, captured_items[1])

    local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
    local found = false
    for _, line in ipairs(lines) do
      if line:find("mini.lua", 1, true) then
        found = true
        break
      end
    end
    assert.is_true(found)
  end)
end)
