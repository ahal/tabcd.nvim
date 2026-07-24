local config = require("tabcd.config")
local discover = require("tabcd.discover")
local label = require("tabcd.label")
local picker = require("tabcd.picker")
local state = require("tabcd.state")

local M = {}

---@param opts TabCDConfig?
function M.setup(opts)
  config.setup(opts)
end

---@param a string
---@param b string
---@return string
local function joinpath(a, b)
  if vim.fs.joinpath then
    return vim.fs.joinpath(a, b)
  end
  return a .. "/" .. b
end

---@param path string
local function tcd(path)
  vim.cmd.tcd(vim.fn.fnameescape(path))
end

---@param root string
---@param opts TabCDConfig
---@param on_choice fun(path: string)
local function do_pick(root, opts, on_choice)
  local relpaths = discover.discover(root, opts)

  if #relpaths == 0 then
    vim.notify("tabcd.nvim: no directories found", vim.log.levels.WARN)
    return
  end

  local items = vim.tbl_map(function(relpath)
    return {
      display = relpath,
      path = joinpath(root, relpath),
    }
  end, relpaths)

  picker.pick(items, { prompt = "TabCD> ", picker = opts.picker, cwd = root }, on_choice)
end

---Pick a directory in the current root and change the current tab's working directory to it.
---@param opts TabCDConfig?
function M.tabcd(opts)
  local resolved = config.resolve(opts)
  local root = state.get_root()
  do_pick(root, resolved, tcd)
end

---Open a new tab, then pick a directory in the current root and change its working directory to it.
---@param opts TabCDConfig?
function M.tabcd_new(opts)
  local resolved = config.resolve(opts)
  local root = state.get_root()
  vim.cmd.tabnew()
  do_pick(root, resolved, tcd)
end

---Get the root captured for this Neovim session.
---@return string
function M.get_root()
  return state.get_root()
end

---Get the abbreviated cwd label for a tab, for use in a tabline/statusline.
---
---This is kept in sync automatically whenever a tab's directory changes and
---is also readable directly as `t:tabcd_name`.
---@param tabnr integer? Tab number as used by `tabpagenr()`. 0 or nil = current tab.
---@return string
function M.get_tab_name(tabnr)
  tabnr = (tabnr == nil or tabnr == 0) and vim.fn.tabpagenr() or tabnr

  local handle = vim.api.nvim_list_tabpages()[tabnr]
  local cached = handle and vim.t[handle].tabcd_name
  if cached then
    return cached
  end

  return label.abbreviate(state.get_root(), vim.fn.getcwd(-1, tabnr))
end

return M
