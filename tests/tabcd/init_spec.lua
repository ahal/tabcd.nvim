describe("tabcd.get_tab_name", function()
  before_each(function()
    package.loaded["tabcd.state"] = nil
    package.loaded["tabcd"] = nil
  end)

  it("falls back to computing from root and cwd when no cache is set", function()
    local state = require("tabcd.state")
    local root = state.get_root()
    local tabcd = require("tabcd")

    assert.equals(vim.fs.basename(root), tabcd.get_tab_name())
  end)

  it("updates when the tab's cwd changes via :tcd, and stays isolated per tab", function()
    -- The autocmd that keeps t:tabcd_name in sync lives in plugin/tabcd.lua,
    -- which --noplugin skips during tests, so source it explicitly here.
    vim.g.loaded_tabcd = nil
    vim.cmd("source plugin/tabcd.lua")

    local state = require("tabcd.state")
    local root = state.get_root()
    local tabcd = require("tabcd")

    local subdir = root .. "/subdir"
    vim.fn.mkdir(subdir, "p")

    vim.cmd("tabnew")
    local ok, err = pcall(vim.cmd.tcd, vim.fn.fnameescape(subdir))
    assert.is_true(ok, err)

    assert.equals("subdir", tabcd.get_tab_name())
    assert.equals("subdir", vim.t.tabcd_name)

    vim.cmd("tabprevious")
    assert.equals(vim.fs.basename(root), tabcd.get_tab_name())

    vim.cmd("tabnext")
    vim.cmd("tabclose")
    vim.fn.delete(subdir, "rf")
  end)
end)
