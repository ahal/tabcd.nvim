plenary_dir := ".tests/plenary.nvim"
telescope_dir := ".tests/telescope.nvim"
snacks_dir := ".tests/snacks.nvim"
fzf_lua_dir := ".tests/fzf-lua"

# Run the unit test suite
test: clone-plenary
    nvim --headless --noplugin -u tests/minimal_init.lua \
        -c "PlenaryBustedDirectory tests/tabcd { minimal_init = 'tests/minimal_init.lua' }"

# Run integration tests against real picker plugins (network access required
# on first run, to vendor telescope/snacks/fzf-lua into .tests/)
test-integration: clone-plenary clone-telescope clone-snacks clone-fzf-lua
    nvim --headless --noplugin -u tests/integration/minimal_init.lua \
        -c "PlenaryBustedDirectory tests/integration { minimal_init = 'tests/integration/minimal_init.lua' }"

# Fetch plenary.nvim if it isn't already vendored
clone-plenary:
    just _clone-latest nvim-lua/plenary.nvim {{ plenary_dir }}

# Fetch telescope.nvim if it isn't already vendored
clone-telescope:
    just _clone-latest nvim-telescope/telescope.nvim {{ telescope_dir }}

# Fetch snacks.nvim if it isn't already vendored
clone-snacks:
    just _clone-latest folke/snacks.nvim {{ snacks_dir }}

# Fetch fzf-lua if it isn't already vendored
clone-fzf-lua:
    just _clone-latest ibhagwan/fzf-lua {{ fzf_lua_dir }}

# Clone the latest tagged release of `repo` into `dir`, or its default branch
# if it has no releases (many nvim plugins are rolling-release with no tags).
_clone-latest repo dir:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -d "{{ dir }}" ]; then
        exit 0
    fi
    tag=$(curl -sf "https://api.github.com/repos/{{ repo }}/releases/latest" \
        | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/' || true)
    if [ -n "$tag" ]; then
        git clone --depth 1 --branch "$tag" "https://github.com/{{ repo }}" "{{ dir }}"
    else
        git clone --depth 1 "https://github.com/{{ repo }}" "{{ dir }}"
    fi

# Run pre-commit lint hooks (stylua, luacheck) against all files
lint:
    pre-commit run --all-files
