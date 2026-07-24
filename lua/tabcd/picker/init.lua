local M = {}

local adapters = {
  telescope = "tabcd.picker.telescope",
  snacks = "tabcd.picker.snacks",
  fzf = "tabcd.picker.fzf",
  mini = "tabcd.picker.mini",
  select = "tabcd.picker.select",
}

-- Order in which installed pickers are auto-detected.
local detect_order = { "telescope", "snacks", "fzf", "mini" }

---@param name string
---@return boolean
local function is_available(name)
  if name == "telescope" then
    return (pcall(require, "telescope"))
  elseif name == "snacks" then
    local ok, snacks = pcall(require, "snacks")
    return ok and snacks.picker ~= nil
  elseif name == "fzf" then
    return (pcall(require, "fzf-lua"))
  elseif name == "mini" then
    return (pcall(require, "mini.pick"))
  elseif name == "select" then
    return true
  end
  return false
end

---@param configured string?
---@return string
local function resolve_name(configured)
  if configured then
    if is_available(configured) then
      return configured
    end
    vim.notify(
      ("tabcd.nvim: configured picker %q is not available, falling back to auto-detect"):format(configured),
      vim.log.levels.WARN
    )
  end

  for _, name in ipairs(detect_order) do
    if is_available(name) then
      return name
    end
  end

  return "select"
end

---@param items { display: string, path: string }[]
---@param opts { prompt: string, picker: string? }
---@param on_choice fun(path: string)
function M.pick(items, opts, on_choice)
  opts = opts or {}
  local name = resolve_name(opts.picker)
  local adapter = require(adapters[name])
  adapter.pick(items, opts, on_choice)
end

---Resolve which picker would be used, without actually picking anything.
---@param configured string?
---@return string
function M.resolve_name(configured)
  return resolve_name(configured)
end

return M
