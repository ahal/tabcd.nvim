describe("TabCD/TabCDNew commands", function()
  before_each(function()
    -- The commands live in plugin/tabcd.lua, which --noplugin skips during
    -- tests, so source it explicitly here.
    vim.g.loaded_tabcd = nil
    vim.cmd("source plugin/tabcd.lua")
  end)

  it("completes directory paths for TabCD and TabCDNew", function()
    local state = require("tabcd.state")
    local root = state.get_root()

    local subdir = root .. "/plugin_spec_subdir"
    vim.fn.mkdir(subdir, "p")

    assert.same({ "plugin_spec_subdir/" }, vim.fn.getcompletion("TabCD plugin_spec_sub", "cmdline"))
    assert.same({ "plugin_spec_subdir/" }, vim.fn.getcompletion("TabCDNew plugin_spec_sub", "cmdline"))

    vim.fn.delete(subdir, "rf")
  end)
end)
