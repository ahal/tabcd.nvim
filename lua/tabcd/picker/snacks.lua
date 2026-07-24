local M = {}

---@param items { display: string, path: string }[]
---@param opts { prompt: string }
---@param on_choice fun(path: string)
function M.pick(items, opts, on_choice)
  local Snacks = require("snacks")

  Snacks.picker.pick({
    title = opts.prompt,
    items = vim.tbl_map(function(item)
      -- snacks' default previewer resolves the path via `item.file` (not
      -- `item.path`); without it, every item fails preview with "no `file`".
      -- `item.file` also makes snacks route directories to its built-in
      -- directory-listing previewer instead of trying to read them as files.
      return { text = item.display, path = item.path, file = item.path }
    end, items),
    format = function(item)
      return { { item.text } }
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        on_choice(item.path)
      end
    end,
  })
end

return M
