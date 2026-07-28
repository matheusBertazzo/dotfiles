## Why

Several small pieces of the config have drifted from current Neovim/plugin conventions: a deprecated highlight API, plugin repos that have moved orgs, a plugin that now duplicates built-in Neovim functionality, and a doubled-up icon provider. Individually minor, together they produce deprecation warnings and unnecessary dependencies.

## What Changes

- Replace the deprecated `vim.highlight.on_yank()` (`auto-commands.lua`) with `vim.hl.on_yank()` (Neovim 0.11).
- Update the Mason plugin specs from the transferred `williamboman/*` org to the canonical **`mason-org/*`** (`mason.nvim`, `mason-lspconfig.nvim`).
- Remove `mini.comment` and adopt Neovim's built-in commenting (`gc`/`gcc`, driven by `commentstring`), which covers the same behavior natively since 0.10.
- Deduplicate icon providers: use `mini.icons` with its `nvim-web-devicons` mock and drop the direct `nvim-web-devicons` dependency where it is only present as a compatibility shim.
- **BREAKING** (keymaps): the current `mini.comment` mappings (`<leader>cc`, `<leader>cl`) are replaced by the built-in `gc`/`gcc` operators.

## Capabilities

### New Capabilities
- `editor-hygiene`: Baseline editor conventions for this config — commenting, yank highlighting, icon provisioning, and canonical plugin sources — kept on current Neovim/plugin APIs.

### Modified Capabilities
<!-- None — no existing spec covers these. -->

## Impact

- **Code**: `lua/config/auto-commands.lua` (yank highlight), `lua/plugins/nvim-lspconfig.lua` (mason org), `lua/config/mini.lua` + `lua/plugins/mini.lua` (drop mini.comment), `lua/plugins/which-key.lua` and any icon setup (icon dedup).
- **Dependencies**: removes `mini.comment`; drops the direct `nvim-web-devicons` where mini.icons can shim it. Mason repos change owner (URLs redirect, but specs updated to canonical).
- **Behavior**: commenting keymaps change from `<leader>cc`/`<leader>cl` to built-in `gc`/`gcc`; no functional loss elsewhere; deprecation warning on yank removed.
- **Out of scope**: the completion-stack migration (tracked in `blink-cmp-migration`); resolving the disabled `mini.surround`/`mini.indentscope` conflicts.
