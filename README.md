# tabcd.nvim

Quickly change a tab's working directory to a subdirectory chosen via a picker,
rooted wherever Neovim was first opened. Built for monorepos where you want
different tabs scoped to a different subdirectories, or for when you want to
work across multiple projects at once.

The root is Neovim's current working directory (not necessarily the project
root), captured **once** when the plugin loads. This can either be at Neovim
startup, or on the first command invocation if lazy-loading is used. That root
is then reused for the rest of the Neovim session.

## Install

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "ahal/tabcd.nvim",
  cmd = { "TabCD", "TabCDNew" },
  config = function()
    require("tabcd").setup({
      ...
    })
  end,
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use({
  "ahal/tabcd.nvim",
  config = function()
    require("tabcd").setup({
      ...
    })
  end,
})
```

Calling `setup()` is optional, the plugin works out of the box with defaults.

## Usage

### Change Working Directories

- `:TabCD` - Use a picker to choose a directory in the current root and change
  the current tab's working directory to it.
- `:TabCDNew` - Same as `:TabCD` except open a new tab first.

Alternatively call the underlying functions programmatically:

```lua
require("tabcd").tabcd()
require("tabcd").tabcd_new()
```

Both take an optional directory argument that bypasses the picker entirely.

### Tab Name

Whenever a tab's directory changes, tabcd.nvim computes an abbreviated label
for it. tabcd.nvim doesn't render a tabline itself, it only keeps the label
available for you to use as you see fit.

- `t:tabcd_name` - a tab-scoped variable, readable directly from a `tabline`/
  `guitablabel` format string or from Vimscript.
- `require("tabcd").get_tab_name(tabnr)` - same tab name from Lua

### Examples

#### Create keymaps

```lua
vim.keymap.set("n", "<leader>tc", "<cmd>TabCD<cr>", { desc = "Pick current tab's working directory" })
vim.keymap.set("n", "<leader>tC", "<cmd>TabCDNew<cr>", { desc = "Open a new tab and pick its working directory" })
```

#### Alias `:tcd` and `:tabnew`

```lua
vim.cmd([[cnoreabbrev <expr> tabnew (getcmdtype() ==# ':' && getcmdline() ==# 'tabnew') ? 'TabCDNew' : 'tabnew']])
vim.cmd([[cnoreabbrev <expr> tcd (getcmdtype() ==# ':' && getcmdline() ==# 'tcd') ? 'TabCD' : 'tcd']])
```

Note this only rewrites what you *type* interactively, it has no effect on
`vim.cmd.tabnew()`/`vim.cmd.tcd()` calls made by other plugins or scripts,
which still run the real built-ins.

#### Update tabline

Most tabline plugins support a custom per-tab name function:

```lua
-- tabby.nvim
require("tabby").setup({
  option = {
    tab_name = {
      name_fallback = function(tabid)
        return require("tabcd").get_tab_name(vim.api.nvim_tabpage_get_number(tabid))
      end,
    },
  },
})

-- lualine.nvim
require("lualine").setup({
  tabline = {
    lualine_a = {
      {
        "tabs",
        mode = 2,
        fmt = function(_, tab)
          return require("tabcd").get_tab_name(tab.tabnr)
        end,
      },
    },
  },
})

-- bufferline.nvim
require("bufferline").setup({ options = { mode = "tabs" } })
vim.api.nvim_create_autocmd("DirChanged", {
  pattern = "tabpage",
  callback = function()
    vim.t.name = require("tabcd").get_tab_name()
  end,
})
```

## Configuration

```lua
require("tabcd").setup({
  -- Max depth to search for directories.
  -- 1 = top-level dirs only. 2 = top-level dirs + their children. etc.
  depth = 2,

  -- Force a specific picker: "telescope" | "snacks" | "fzf" | "select".
  -- nil = auto-detect (telescope > snacks > fzf-lua > vim.ui.select).
  picker = nil,

  -- Include dotfile directories in discovery.
  hidden = false,

  -- Also offer the root itself as a pick.
  include_root = false,

  fd = {
    -- Override the fd binary to use. nil = auto ("fd", then "fdfind").
    cmd = nil,
    -- Extra arguments appended to the fd invocation.
    extra_args = {},
  },
})
```

Options can also be overridden per-call:

```lua
require("tabcd").tabcd({ depth = 3 })
```

## Supported pickers

If any of the following pickers are detected, they will automatically be used.

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [snacks.nvim](https://github.com/folke/snacks.nvim)
- [fzf-lua](https://github.com/ibhagwan/fzf-lua)
- `vim.ui.select` (always available as a fallback)

Run `:checkhealth tabcd` to see which picker is being used.

## Directory discovery

When [`fd`](https://github.com/sharkdp/fd) (or `fdfind`) is installed, it's
used to list directories — this respects `.gitignore` and is fast even on
large monorepos. If `fd` isn't available, a native `vim.fs.dir` walk is used
instead; this fallback does **not** respect `.gitignore`.

Run `:checkhealth tabcd` to see whether `fd` is being used.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for running tests and linting.
