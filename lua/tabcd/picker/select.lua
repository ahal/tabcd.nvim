local M = {}

---@param items { display: string, path: string }[]
---@param opts { prompt: string }
---@param on_choice fun(path: string)
function M.pick(items, opts, on_choice)
  vim.ui.select(items, {
    prompt = opts.prompt,
    format_item = function(item)
      return item.display
    end,
  }, function(choice)
    if choice then
      on_choice(choice.path)
    end
  end)
end

return M
