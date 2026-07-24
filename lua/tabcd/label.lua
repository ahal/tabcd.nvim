local M = {}

---Abbreviate a path relative to root for display as a tab label.
---@param root string
---@param path string
---@return string
function M.abbreviate(root, path)
  local rel = path
  if path == root then
    rel = "."
  elseif vim.startswith(path, root .. "/") then
    rel = path:sub(#root + 2)
  else
    -- path isn't under root (e.g. `:tcd` was given an absolute path outside
    -- it); strip the leading separator so it abbreviates like a normal
    -- relative path instead of producing an empty leading segment.
    rel = rel:gsub("^/", "")
  end

  if rel == "." or rel == "" then
    return vim.fs.basename(root)
  end

  local parts = vim.split(rel, "/", { plain = true })
  for i = 1, #parts - 1 do
    parts[i] = parts[i]:sub(1, 1)
  end
  return table.concat(parts, "/")
end

return M
