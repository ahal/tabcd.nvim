local picker = require("tabcd.picker")

describe("tabcd.picker", function()
  local orig_select, orig_notify

  before_each(function()
    orig_select = vim.ui.select
    orig_notify = vim.notify
  end)

  after_each(function()
    vim.ui.select = orig_select
    vim.notify = orig_notify
  end)

  it("falls back to vim.ui.select when no picker is installed", function()
    local received
    vim.ui.select = function(items, _, cb)
      received = items
      cb(items[1])
    end

    local chosen
    picker.pick({ { display = "a", path = "/a" } }, { prompt = "Test> " }, function(path)
      chosen = path
    end)

    assert.equals(1, #received)
    assert.equals("/a", chosen)
  end)

  it("warns and falls back to auto-detect when the configured picker is unavailable", function()
    local notified
    vim.notify = function(msg, level)
      notified = { msg = msg, level = level }
    end
    vim.ui.select = function(items, _, cb)
      cb(items[1])
    end

    local chosen
    picker.pick({ { display = "a", path = "/a" } }, { picker = "telescope" }, function(path)
      chosen = path
    end)

    assert.is_not_nil(notified)
    assert.equals(vim.log.levels.WARN, notified.level)
    assert.equals("/a", chosen)
  end)
end)
