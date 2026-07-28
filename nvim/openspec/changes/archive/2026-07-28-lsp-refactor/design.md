## Context

The config targets Neovim 0.11.5 and locks `mason-lspconfig` to 2.1.0 (`main` branch). The 2.0 rewrite removed the `handlers`/`setup_handlers` API and added `automatic_enable = true` (default), which calls `vim.lsp.enable(<server>)` for every installed server. The current `lua/config/lsp.lua` still passes a `handlers` closure that calls `require('lspconfig')[name].setup(...)` to attach capabilities and per-server settings — verified to be dropped: `handlers` appears nowhere in the installed mason-lspconfig source, and `automatic_enable.lua` enables servers with no capabilities/settings.

Confirmed facts from the installed plugins:
- `cmp_nvim_lsp.setup()` only registers an `InsertEnter` completion hook; it does **not** broadcast capabilities — the user must wire them.
- `cmp_nvim_lsp.default_capabilities()` sets `snippetSupport = true` and `resolveSupport`, which is exactly what is currently lost.
- `lazydev.nvim` dynamically injects `$VIMRUNTIME` into `lua_ls` `workspace.library`, which both defines the `vim` global and supplies `vim.*` types.
- lazydev registers a cmp source named `lazydev` but it is not present in the current `cmp.setup` `sources`.

## Goals / Non-Goals

**Goals:**
- Capabilities from `cmp_nvim_lsp` actually reach every server.
- The `servers` table becomes an effective per-server configuration surface.
- Remove dead indirection (`handlers` closure, direct `require('lspconfig')` setup calls).
- Use the Neovim 0.11 native LSP config API idiomatically.
- Fix the deprecated diagnostic-jump keymaps.

**Non-Goals:**
- TreeSitter changes (separate change).
- Migrating from nvim-cmp to blink.cmp.
- Reworking the Java/`nvim-jdtls` startup flow (only optional capability-helper dedupe).
- Adding new language servers beyond the current set.

## Decisions

### Decision: Use `vim.lsp.config('*')` for capabilities, per-server `vim.lsp.config(name)` for settings

Set capabilities once on the wildcard config, then loop the `servers` table applying overrides. Neovim merges wildcard config, nvim-lspconfig's `lsp/<name>.lua`, and the per-name config, resolving at attach time.

- **Why over the handlers closure**: the closure is silently ignored by mason-lspconfig 2.x; the native API is the supported path and needs no framework glue.
- **Alternative considered**: pass `capabilities` inside each per-server table. Rejected — duplicates the capability line per server; the `'*'` wildcard expresses "all servers" once.
- **Alternative considered**: keep `require('lspconfig')[name].setup()`. Rejected — redundant with `automatic_enable`, risks double-enabling, and couples to the framework being phased out.

### Decision: Rely on mason-lspconfig `automatic_enable` (default) for enablement

Reduce `mason-lspconfig.setup` to `{ ensure_installed = vim.tbl_keys(servers) }`. Do not call `vim.lsp.enable` manually and do not disable `automatic_enable`.

- **Why**: avoids double enablement and keeps a single source of truth for which servers are on.
- **Ordering constraint**: all `vim.lsp.config(...)` calls must run before `mason-lspconfig.setup(...)`. Config is resolved at buffer attach (forgiving), but defining first is the clean, race-free model.

### Decision: Let lazydev own Lua globals/types; drop the `diagnostics.globals` hardcode

Leave `lua_ls = {}` (no hardcoded globals) and add `{ name = "lazydev", group_index = 0 }` to cmp sources.

- **Why**: lazydev already supplies both the `vim` global (killing the undefined-global warning) and `vim.*` types (completions). The hardcode only ever silenced the warning half and is redundant once capabilities are correctly wired and lazydev attaches.
- **Verification-gated**: removal is confirmed by the acceptance scenarios (no undefined-global warning; `vim.api.nvim_` completes). If lazydev is found not to attach, the fallback is to restore the hardcode — but the expectation is it works.

### Decision: Replace deprecated diagnostic jumps

`vim.diagnostic.goto_prev()` → `vim.diagnostic.jump({ count = -1 })`; `goto_next()` → `vim.diagnostic.jump({ count = 1 })`, expressed as Lua callbacks rather than `<cmd>lua ...<cr>` strings for consistency with the surrounding keymaps.

### Decision (optional): Shared capabilities helper

The Java config (`java-jdtls.lua:24-28`) hand-rolls the same cmp capabilities. Optionally extract a `lua/config/utils/lsp-capabilities.lua` returning `cmp_nvim_lsp.default_capabilities()` and consume it in both places. Low priority; kept optional to keep the core change small.

## Risks / Trade-offs

- **lazydev does not attach on this machine → Lua regressions** → Gated by acceptance scenarios; fallback is restoring `diagnostics.globals = {'vim'}`.
- **A future `mason-lspconfig` change to `automatic_enable` defaults** → documented reliance on the default; if it changes, add explicit `vim.lsp.enable(vim.tbl_keys(servers))`.
- **Capability merge surprises for a specific server** → `vim.lsp.config` deep-merges; verify per-server behavior for any server that declares its own capabilities upstream.
- **Ordering mistake (setup before config)** → mitigated by the explicit ordering constraint and a task step; attach-time resolution also softens the impact.

## Migration Plan

1. Rewrite the top of `lua/config/lsp.lua` (capabilities, `servers` table, `vim.lsp.config` calls, `mason-lspconfig.setup`).
2. Remove the `handlers` closure and the `require('lspconfig')` setup call.
3. Add the lazydev cmp source; update diagnostic keymaps.
4. Reload Neovim; run the acceptance checks (snippetSupport true; Lua global/completions; a per-server setting takes effect).
5. **Rollback**: revert `lua/config/lsp.lua`; the prior state still starts servers (via `automatic_enable`), so rollback is safe and self-contained.

## Open Questions

- Do we take the optional shared-capabilities helper now, or defer it? (Leaning defer to keep the change focused.)
