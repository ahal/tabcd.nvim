local config = require("tabcd.config")
local discover = require("tabcd.discover")
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

---Pick a directory in the current root and :tcd into it.
---@param opts TabCDConfig?
function M.tabcd(opts)
  local resolved = config.resolve(opts)
  local root = state.get_root()
  do_pick(root, resolved, tcd)
end

---Open a new tab, then pick a directory in the current root and :tcd into it.
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

return M
