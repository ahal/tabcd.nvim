local M = {}

---@param items { display: string, path: string }[]
---@param opts { prompt: string, cwd: string }
---@param on_choice fun(path: string)
function M.pick(items, opts, on_choice)
  local fzf = require("fzf-lua")

  local displays = {}
  local by_display = {}
  for _, item in ipairs(items) do
    table.insert(displays, item.display)
    by_display[item.display] = item.path
  end

  fzf.fzf_exec(displays, {
    prompt = opts.prompt,
    cwd = opts.cwd,
    -- Directory entries can't be `bat`/`cat`'d (fzf-lua's default previewer),
    -- so disable it and preview a listing of the directory's contents instead.
    previewer = false,
    preview = "ls -la --color=always {}",
    actions = {
      ["default"] = function(selected)
        local path = by_display[selected[1]]
        if path then
          on_choice(path)
        end
      end,
    },
  })
end

return M
