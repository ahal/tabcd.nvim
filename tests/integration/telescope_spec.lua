-- Exercises the real telescope.nvim library, not a hand-written stub. Our
-- adapter never sets a `previewer`, relying on telescope defaulting to none
-- for a picker built this way; this guards against that assumption silently
-- breaking in a future telescope release (the same class of bug we hit with
-- fzf-lua and snacks defaulting to an active file previewer instead).
describe("tabcd.picker.telescope integration", function()
  it("does not attach a previewer for our directory entries", function()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values

    local picker = pickers.new({}, {
      prompt_title = "Tabcd> ",
      finder = finders.new_table({
        results = { { display = "apps", path = "/tmp/fixture/apps" } },
        entry_maker = function(item)
          return { value = item, display = item.display, ordinal = item.display }
        end,
      }),
      sorter = conf.generic_sorter({}),
    })

    assert.is_false(picker.previewer)
  end)
end)
