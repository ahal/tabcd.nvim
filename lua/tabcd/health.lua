local M = {}

local picker_display_names = {
  telescope = "telescope.nvim",
  snacks = "snacks.nvim",
  fzf = "fzf-lua",
  mini = "mini.pick",
  select = "vim.ui.select",
}

function M.check()
  vim.health.start("tabcd.nvim")

  local config = require("tabcd.config")
  local discover = require("tabcd.discover")
  local picker = require("tabcd.picker")
  local state = require("tabcd.state")

  vim.health.ok(("Root: `%s`"):format(state.get_root()))

  local fd_cmd = discover.find_fd_cmd(config.options.fd and config.options.fd.cmd)
  if fd_cmd then
    local version = discover.fd_version(fd_cmd)
    if version then
      vim.health.ok(("fd found: `%s`"):format(version))
    else
      vim.health.ok("fd found")
    end
  else
    vim.health.warn("fd not found on PATH", {
      "Directory discovery will fall back to a native vim.fs.dir walk, which does not"
        .. " respect .gitignore and may be slower with large roots.",
      "Install fd: https://github.com/sharkdp/fd#installation",
    })
  end

  local picker_name = picker.resolve_name(config.options.picker)
  local picker_display = picker_display_names[picker_name] or picker_name
  if picker_name == "select" then
    vim.health.warn(("Using picker: %s (fallback)"):format(picker_display), {
      "No supported picker plugin was found: telescope.nvim, snacks.nvim, fzf-lua, mini.pick.",
    })
  else
    vim.health.ok(("Using picker: %s"):format(picker_display))
  end
end

return M
