if vim.g.loaded_tabcd then
  return
end
vim.g.loaded_tabcd = true

-- Capture the root as early as possible: at Neovim startup for
-- eagerly-loaded setups, or on first command invocation for plugin managers
-- that lazy-load this plugin via `cmd = { "TabCD", "TabCDNew" }`.
require("tabcd.state").set_root()

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
