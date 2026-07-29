## Why

The completion setup is the legacy nvim-cmp stack — six plugins (`nvim-cmp`, `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `cmp_luasnip`, plus glue) wired together by hand in `lua/config/lsp.lua`. `blink.cmp` is the current-generation completion engine: a single plugin with built-in LSP/path/snippet/buffer sources, native signature help, a faster (Rust) fuzzy matcher, and first-class integration with the Neovim 0.11 `vim.lsp.config` capabilities pattern this config already uses. Migrating consolidates six dependencies into one and removes the bespoke cmp wiring.

## What Changes

- Add `Saghen/blink.cmp` (pinned to a `1.*` release for prebuilt binaries) and configure sources: `lsp`, `path`, `snippets`, `buffer`, plus `lazydev`.
- **Keep LuaSnip as the snippet engine** (`snippets = { preset = 'luasnip' }`) so the existing custom vscode-style snippets under `snippets/vscode/` continue to load and expand, including choice nodes.
- Source LSP client capabilities from `require('blink.cmp').get_lsp_capabilities()` and broadcast them via the existing `vim.lsp.config('*', { capabilities })`.
- Wire lazydev's `require`-path completion through blink's native lazydev provider (replacing the nvim-cmp `lazydev` source).
- Preserve current completion keymaps as closely as possible (Tab/S-Tab select, `<CR>`/`<C-y>` confirm, `<C-e>` hide, `<C-u>`/`<C-d>` scroll docs, snippet jump/choice).
- **BREAKING**: remove `nvim-cmp`, `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `cmp_luasnip` and the entire `cmp.setup{...}` block in `lua/config/lsp.lua`.

## Capabilities

### New Capabilities
- `completion-engine`: The autocompletion engine, its sources, snippet integration, LSP capability broadcast, and keymaps.

### Modified Capabilities
- `lsp-configuration`: the "Client capabilities broadcast to all servers" requirement changes its capability source from `cmp_nvim_lsp.default_capabilities()` to `blink.cmp.get_lsp_capabilities()`.

## Impact

- **Code**: `lua/config/lsp.lua` (capabilities line + delete the `cmp.setup` block), `lua/plugins/nvim-lspconfig.lua` (remove cmp plugins), new `lua/plugins/blink.lua`. LuaSnip and friendly-snippets remain.
- **Dependencies**: removes 5 cmp-related plugins; adds `blink.cmp`. Keeps `LuaSnip`, `friendly-snippets`.
- **Behavior**: same or better completion (native signature help, fuzzy matching); custom snippets preserved; capabilities still reach all servers.
- **Out of scope**: dropping LuaSnip for blink-native snippets (kept deliberately); Tier A hygiene (separate `config-hygiene` change).
