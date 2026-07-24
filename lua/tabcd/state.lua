local M = {}

---@type string?
local root

---Set the session's root to the current working directory. Can be called
---again later to update the root; the plugin itself only ever calls this
---once, on first load.
function M.set_root()
  root = vim.fn.getcwd()
end

---Get the session's root, capturing it now if it hasn't been set yet.
---@return string
function M.get_root()
  if root == nil then
    M.set_root()
  end
  return root
end

return M
