local M = {}

---@param items { display: string, path: string }[]
---@param opts { prompt: string }
---@param on_choice fun(path: string)
function M.pick(items, opts, on_choice)
  local MiniPick = require("mini.pick")

  MiniPick.start({
    source = {
      items = vim.tbl_map(function(item)
        return { text = item.display, path = item.path }
      end, items),
      name = opts.prompt,
      choose = function(item)
        if item then
          on_choice(item.path)
        end
      end,
    },
  })
end

return M
