-- Exercises the real fzf-lua library, not a hand-written stub: fzf-lua
-- defaults to a `bat`/`cat`-based previewer that errors on our directory
-- entries unless we explicitly disable it, and a stub would just re-encode
-- the (wrong) assumption that no previewer runs by default.
describe("tabcd.picker.fzf integration", function()
  local orig_fzf_preload

  before_each(function()
    orig_fzf_preload = package.preload["fzf-lua"]
    package.loaded["fzf-lua"] = nil
    package.loaded["tabcd.picker.fzf"] = nil
  end)

  after_each(function()
    package.preload["fzf-lua"] = orig_fzf_preload
  end)

  it("disables the default previewer and sets a directory-listing preview command", function()
    local captured_opts
    package.preload["fzf-lua"] = function()
      return {
        fzf_exec = function(_, opts)
          captured_opts = opts
        end,
      }
    end

    local picker = require("tabcd.picker.fzf")
    picker.pick({ { display = "apps", path = "/tmp/fixture/apps" } }, {
      prompt = "Tabcd> ",
      cwd = vim.fn.getcwd(),
    }, function() end)

    -- Load the real fzf-lua (not our stub above) to resolve previewer/preview
    -- the same way `fzf_exec` does internally. fzf-lua's `utils.lua` has a
    -- one-time Lua-5.1-compat shim (rewriting an internal icon-separator
    -- string) gated on `_VERSION` looking like "Lua 5.1", which errors when
    -- first loaded under plenary's test runner for reasons unrelated to
    -- anything this test cares about; mask `_VERSION` just long enough to
    -- skip that branch so the module loads.
    package.preload["fzf-lua"] = nil
    package.loaded["fzf-lua"] = nil
    local orig_version = _G._VERSION
    _G._VERSION = "Lua 5.4"
    local config = require("fzf-lua.config")
    local previewer = require("fzf-lua.previewer")
    _G._VERSION = orig_version

    local normalized = config.normalize_opts(captured_opts, {})

    -- No Lua-side previewer object is attached, so fzf-lua can't fall back
    -- to its default bat/cat previewer regardless of the user's own config.
    assert.is_nil(previewer.new(normalized.previewer, normalized))
    -- The raw preview command survives normalization unchanged, which is
    -- what ultimately becomes the native `--preview` flag fzf itself runs.
    assert.equals("ls -la --color=always {}", normalized.preview)
  end)
end)
