local M = {}

---@class TabCDConfig
---@field depth integer Max depth to search for directories. 1 = top-level only.
---@field picker? "telescope"|"snacks"|"fzf"|"mini"|"select" Force a specific picker. nil = auto-detect.
---@field hidden boolean Include dotfile directories in discovery.
---@field include_root boolean Offer the root itself as a pick.
---@field fd { cmd: string?, extra_args: string[] }

---@type TabCDConfig
M.defaults = {
  depth = 2,
  picker = nil,
  hidden = false,
  include_root = false,
  fd = {
    cmd = nil,
    extra_args = {},
  },
}

---@type TabCDConfig
M.options = vim.deepcopy(M.defaults)

---Merge user config over the defaults.
---@param opts TabCDConfig?
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
end

---Resolve effective config for a single call, merging per-call overrides.
---@param opts TabCDConfig?
---@return TabCDConfig
function M.resolve(opts)
  if not opts then
    return M.options
  end
  return vim.tbl_deep_extend("force", M.options, opts)
end

return M
