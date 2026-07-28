## Why

The LSP setup in `lua/config/lsp.lua` relies on `mason-lspconfig`'s `handlers` API, which was **removed** in the 2.0 rewrite (the config is locked to `mason-lspconfig` 2.1.0 on the `main` branch). The `handlers` table is silently dropped, so two things that the config *appears* to do never actually happen:

- The `cmp_nvim_lsp` capabilities (snippet support, completion-item resolve, etc.) are never broadcast to any server.
- The per-server `servers = {}` settings table is inert — `lua_ls`, `yamlls`, and friends run on nvim-lspconfig defaults with zero custom configuration.

Servers still start (mason-lspconfig 2.x auto-enables installed servers via `vim.lsp.enable`), which masks the breakage. Neovim 0.11 ships a native LSP configuration API (`vim.lsp.config` / `vim.lsp.enable`) that both fixes the bug and removes the handler indirection entirely.

## What Changes

- Replace the dead `handlers` block with the Neovim 0.11 native API: broadcast capabilities once via `vim.lsp.config('*', { capabilities })`, then layer per-server overrides via `vim.lsp.config(name, cfg)` in a loop.
- **BREAKING** (internal): stop using the `require('lspconfig')` framework for server setup; rely on `mason-lspconfig`'s default `automatic_enable` to call `vim.lsp.enable` for installed servers.
- Reduce `mason-lspconfig.setup` to just `ensure_installed` (keys of the `servers` table).
- Remove the `lua_ls` `diagnostics.globals = {'vim'}` hardcode and let `lazydev.nvim` own the Neovim runtime/global injection (it already provides both the `vim` global and `vim.*` types).
- Add `{ name = "lazydev", group_index = 0 }` to the nvim-cmp sources so lazydev's registered `require("...")` module-path completion is actually used.
- Replace the deprecated `vim.diagnostic.goto_prev()` / `goto_next()` keymaps with `vim.diagnostic.jump({ count })` (0.11 deprecation).
- Java (`nvim-jdtls`) is out of scope for the enable path, but its hand-rolled capabilities block (`java-jdtls.lua:24-28`) is the one remaining duplicate of the cmp-capabilities line and may optionally be routed through a shared helper.

## Capabilities

### New Capabilities
- `lsp-configuration`: How language servers are configured, given client capabilities, and enabled in Neovim 0.11 — covering capability broadcast, per-server settings, server enablement, Lua development ergonomics, and diagnostic navigation keymaps.

### Modified Capabilities
<!-- None — no existing specs in openspec/specs/. -->

## Impact

- **Code**: `lua/config/lsp.lua` (server table, capabilities, mason-lspconfig setup, cmp sources, diagnostic keymaps). Optionally `lua/plugins/java-jdtls.lua` and a new `lua/config/utils/` capabilities helper.
- **Dependencies**: No plugin additions/removals. Relies on already-installed `mason-lspconfig` 2.1.0 (`automatic_enable`), `lazydev.nvim`, and Neovim 0.11's native `vim.lsp.config`/`vim.lsp.enable`.
- **Behavior**: Language servers gain full client capabilities (LSP snippet expansion, completion resolve); per-server settings become effective for the first time; Lua completions/globals come exclusively from lazydev.
- **Out of scope**: TreeSitter changes (tracked separately); migrating off nvim-cmp to blink.cmp.
