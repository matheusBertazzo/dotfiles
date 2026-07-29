## Context

Completion currently lives in `lua/config/lsp.lua` as a hand-wired `cmp.setup{...}` (sources, formatting, ~15 keymaps) plus five cmp plugins in `lua/plugins/nvim-lspconfig.lua`. Capabilities are already broadcast via `vim.lsp.config('*', {...})` (from the archived `lsp-refactor`). The user has custom vscode-style snippets under `snippets/vscode/` loaded through LuaSnip, including choice nodes. lazydev is present and its completion currently rides on an nvim-cmp source.

blink.cmp (`Saghen/blink.cmp`) provides built-in `lsp`/`path`/`snippets`/`buffer` sources, a Rust fuzzy matcher (prebuilt binaries on tagged releases), native signature help, and a `get_lsp_capabilities()` helper.

## Goals / Non-Goals

**Goals:**
- Replace the six-plugin cmp stack with blink.cmp.
- Preserve custom snippets by keeping LuaSnip as the engine.
- Keep capabilities flowing to servers via the existing `vim.lsp.config('*')`.
- Preserve completion keymaps as closely as blink allows.

**Non-Goals:**
- Dropping LuaSnip for blink-native snippets (would break custom snippets/choice nodes).
- Changing LSP server setup, TreeSitter, or Tier A hygiene items.

## Decisions

### Decision: Keep LuaSnip as the snippet engine

Configure `snippets = { preset = 'luasnip' }` and keep the `luasnip.loaders.from_vscode` loading in `lua/config/lsp.lua` (or move it into the blink plugin file).

- **Why**: the user has custom vscode-style snippets and choice nodes; blink's native snippet support does not cover LuaSnip choice nodes.
- **Alternative**: blink-native snippets — rejected, would regress custom snippets.

### Decision: Capabilities from blink

Set `local capabilities = require('blink.cmp').get_lsp_capabilities()` in `lua/config/lsp.lua` and keep `vim.lsp.config('*', { capabilities = capabilities })`.

- **Why**: single source of truth; blink advertises its own completion capabilities (incl. snippetSupport). The verification from lsp-refactor (`snippetSupport == true`) still holds.

### Decision: lazydev via blink's native provider

Add a `lazydev` provider to blink sources: `providers.lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 }` and include `'lazydev'` in `sources.default`.

- **Why**: lazydev ships a blink integration module; this replaces the removed nvim-cmp lazydev source cleanly.

### Decision: Keymap mapping strategy

Use a custom blink `keymap` table (base off the `default` preset) mapping to the prior behavior where a blink equivalent exists:

| Intent | Old (cmp) | blink |
|---|---|---|
| select next / prev | `<Tab>`/`<S-Tab>`, `<Down>`/`<Up>` | `select_next` / `select_prev` |
| confirm | `<CR>` (no preselect), `<C-y>` (select) | `<CR>`/`<C-y>` → `accept` |
| hide/abort | `<C-e>` | `hide` |
| scroll docs | `<C-u>`/`<C-d>` | `scroll_documentation_up`/`_down` |
| snippet jump | `<C-n>`/`<C-p>` | `snippet_forward`/`snippet_backward` |
| luasnip choice | `<C-l>`/`<C-h>` | standalone `{i,s}` LuaSnip keymaps (NOT blink) |

- **Trade-off**: `<C-n>`/`<C-p>` were snippet-jump in the old config (unusual — normally menu nav). Preserving them as snippet jump keeps muscle memory; the menu uses Tab/arrows.
- **Choice nodes must be standalone, and must NOT be expr mappings**: blink only applies its built-in snippet commands (not custom functions) in select mode (`keymap/apply.lua`), which is where LuaSnip choice nodes are active. So `<C-l>`/`<C-h>` are set as standalone `vim.keymap.set({'i','s'}, ...)` in `lua/config/lsp.lua`. They must be plain (non-`expr`) callbacks: `luasnip.change_choice()` modifies the buffer, which is forbidden under an `expr` mapping's textlock (an earlier `expr` attempt silently no-op'd the cycling and fed a literal `^L`). When no choice is active, the callback falls through via `nvim_feedkeys(<key>, 'n', ...)` so `<C-h>` still deletes the previous char and `<C-l>` does nothing (i_CTRL-L is unused).

### Decision: Pin blink to a tagged release

Use `version = '1.*'` so lazy.nvim fetches prebuilt fuzzy-matcher binaries (no Rust toolchain / `cargo build` needed).

## Risks / Trade-offs

- **Prebuilt binary availability for the platform (darwin/arm64)** → `version = '1.*'` ships binaries; if missing, fall back to `build = 'cargo build --release'` (needs Rust).
- **LuaSnip choice-node keymaps** → blink has no built-in choice cycling; implement as small custom keymap fns (as today).
- **Signature help / docs behavior differs subtly** → acceptable; blink's native signature help replaces the old `gs`-triggered `vim.lsp.buf.signature_help` if desired (keep the existing `gs` map regardless).
- **lazydev blink module name drift** → pin lazydev, verify the integration module path exists.

## Migration Plan

1. Add `lua/plugins/blink.lua` (`Saghen/blink.cmp`, `version = '1.*'`, deps: LuaSnip + friendly-snippets), with sources, luasnip preset, lazydev provider, and keymaps.
2. In `lua/config/lsp.lua`: swap capabilities to `blink.cmp.get_lsp_capabilities()`; delete the `cmp.setup{...}` block; keep the LuaSnip vscode loader.
3. Remove `nvim-cmp`, `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `cmp_luasnip` from `lua/plugins/nvim-lspconfig.lua`.
4. `:Lazy sync`; verify LSP/path/buffer/snippet/lazydev completion, custom snippet expansion, and `snippetSupport == true`.
5. **Rollback**: restore the cmp plugins + `cmp.setup` block and the `cmp_nvim_lsp` capabilities line; remove `blink.lua`.

## Open Questions

- Resolved: preserve the exact prior maps (Tab/S-Tab select, `<CR>`/`<C-y>` confirm, `<C-e>` hide, `<C-u>`/`<C-d>` scroll docs, `<C-n>`/`<C-p>` snippet jump, `<C-l>`/`<C-h>` LuaSnip choice), including the unusual `<C-n>`/`<C-p>` snippet-jump binding. Not adopting a stock preset.
