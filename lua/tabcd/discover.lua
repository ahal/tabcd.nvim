local M = {}

---Find an available fd binary.
---@param opt_cmd string?
---@return string?
function M.find_fd_cmd(opt_cmd)
  if opt_cmd then
    return vim.fn.executable(opt_cmd) == 1 and opt_cmd or nil
  end
  for _, cmd in ipairs({ "fd", "fdfind" }) do
    if vim.fn.executable(cmd) == 1 then
      return cmd
    end
  end
  return nil
end

---Get the version string reported by an fd binary.
---@param fd_cmd string
---@return string?
function M.fd_version(fd_cmd)
  local out, ok
  if vim.system then
    local result = vim.system({ fd_cmd, "--version" }, { text = true }):wait()
    ok = result.code == 0
    out = result.stdout or ""
  else
    local lines = vim.fn.systemlist({ fd_cmd, "--version" })
    ok = vim.v.shell_error == 0
    out = table.concat(lines, "\n")
  end

  if not ok then
    return nil
  end

  return vim.trim(out)
end

---Discover directories using fd, relative to root.
---@param root string
---@param opts TabCDConfig
---@return string[]?
local function fd_discover(root, opts)
  local fd_cmd = M.find_fd_cmd(opts.fd and opts.fd.cmd)
  if not fd_cmd then
    return nil
  end

  local args = {
    fd_cmd,
    "--type",
    "d",
    "--max-depth",
    tostring(opts.depth),
    "--base-directory",
    root,
  }
  if opts.hidden then
    table.insert(args, "--hidden")
  end
  vim.list_extend(args, (opts.fd and opts.fd.extra_args) or {})

  local out, ok
  if vim.system then
    local result = vim.system(args, { text = true }):wait()
    ok = result.code == 0
    out = result.stdout or ""
  else
    local lines = vim.fn.systemlist(args)
    ok = vim.v.shell_error == 0
    out = table.concat(lines, "\n")
  end

  if not ok then
    return nil
  end

  local results = {}
  for line in out:gmatch("[^\r\n]+") do
    -- fd appends a trailing slash to directory results; strip it.
    table.insert(results, (line:gsub("/$", "")))
  end
  return results
end

---Discover directories using a native vim.fs.dir walk.
---@param root string
---@param opts TabCDConfig
---@return string[]
local function native_discover(root, opts)
  local hidden = opts.hidden
  local results = {}

  local function is_hidden(name)
    return vim.startswith(name, ".")
  end

  local ok = pcall(function()
    for name, type in
      vim.fs.dir(root, {
        depth = opts.depth,
        skip = function(dir_name)
          -- Return false to stop descending into this directory.
          return hidden or not is_hidden(vim.fs.basename(dir_name))
        end,
      })
    do
      if type == "directory" and (hidden or not is_hidden(vim.fs.basename(name))) then
        table.insert(results, name)
      end
    end
  end)

  if not ok then
    return {}
  end

  return results
end

---Discover directories under root, up to opts.depth.
---@param root string
---@param opts TabCDConfig
---@return string[] relpaths Directory paths relative to root, sorted.
function M.discover(root, opts)
  local results = fd_discover(root, opts)
  if results == nil then
    results = native_discover(root, opts)
  end

  table.sort(results)

  if opts.include_root then
    table.insert(results, 1, ".")
  end

  return results
end

return M
