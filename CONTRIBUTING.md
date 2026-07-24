# Contributing

## Testing

Tests use [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)'s busted-style
harness, the standard for testing Neovim plugins. Run them with
[`just`](https://github.com/casey/just):

```sh
just test
```

This vendors plenary.nvim into `.tests/plenary.nvim` on first run (git clone,
requires network access), then runs `tests/tabcd/*_spec.lua` headlessly. These
are unit tests only — picker adapters are tested against hand-written stubs,
not the real picker plugins.

### Integration tests

```sh
just test-integration
```

`tests/integration/*_spec.lua` exercises each picker adapter against the real
telescope.nvim, snacks.nvim, and fzf-lua libraries instead of stubs, asserting
on their actual behavior (e.g. "does this item shape resolve to a path snacks
can preview?"). This is what catches drift between our assumptions and a
picker's real internals — the kind of bug a hand-written stub can't catch,
since the stub just encodes the same assumption being tested.

This is slower and needs network access: it vendors telescope.nvim, snacks.nvim,
and fzf-lua into `.tests/` on first run — pinned to each plugin's latest tagged
release if it has one (currently only snacks.nvim does; telescope.nvim and
fzf-lua are rolling-release, so their default branch is used, matching how most
users actually run them).

## Linting

Linting uses [pre-commit](https://pre-commit.com/) with the standard Lua/Neovim
plugin tooling:

- [StyLua](https://github.com/JohnnyMorganz/StyLua) — formatting (config in `stylua.toml`)
- [Luacheck](https://github.com/mpeterv/luacheck) — static analysis (config in `.luacheckrc`);
  install it via `luarocks install luacheck`

Run all hooks against the whole repo with:

```sh
just lint
```

To also run the hooks automatically on `git commit`, install them once per clone:

```sh
pre-commit install
```
