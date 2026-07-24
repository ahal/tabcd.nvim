if vim.g.loaded_tabcd then
  return
end
vim.g.loaded_tabcd = true

-- Capture the root as early as possible: at Neovim startup for
-- eagerly-loaded setups, or on first command invocation for plugin managers
-- that lazy-load this plugin via `cmd = { "TabCD", "TabCDNew" }`.
require("tabcd.state").set_root()

-- Keep t:tabcd_name in sync with the tab's cwd, so it can be read directly
-- (e.g. from a tabline) without calling back into Lua.
vim.api.nvim_create_autocmd("DirChanged", {
  group = vim.api.nvim_create_augroup("tabcd", { clear = true }),
  pattern = "tabpage",
  desc = "Update t:tabcd_name to reflect the tab's new cwd",
  callback = function(args)
    vim.t.tabcd_name = require("tabcd.label").abbreviate(require("tabcd.state").get_root(), args.file)
  end,
})

vim.api.nvim_create_user_command("TabCD", function(cmd_opts)
  if cmd_opts.args ~= "" then
    vim.cmd.tcd(cmd_opts.args)
  else
    require("tabcd").tabcd()
  end
end, {
  nargs = "?",
  complete = "dir",
  desc = "Pick a directory and change the current tab's working directory to it.",
})

vim.api.nvim_create_user_command("TabCDNew", function(cmd_opts)
  if cmd_opts.args ~= "" then
    vim.cmd.tabnew()
    vim.cmd.tcd(cmd_opts.args)
  else
    require("tabcd").tabcd_new()
  end
end, {
  nargs = "?",
  complete = "dir",
  desc = "Open a new tab then pick a directory and change its working directory to it.",
})
