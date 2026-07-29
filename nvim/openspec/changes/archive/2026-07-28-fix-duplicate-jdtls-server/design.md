## Context

Java in this config is intentionally driven by `nvim-jdtls` (`lua/plugins/java-jdtls.lua`), which builds a rich JDTLS `config` (project-specific workspace dir, DAP + test bundles, Java keymaps) and calls `require("jdtls").start_or_attach(config)` on every `FileType java`.

Separately, `lua/config/lsp.lua` calls `mason-lspconfig.setup { ensure_installed = vim.tbl_keys(servers) }`. In the current `mason-org/mason-lspconfig.nvim` (main branch), `automatic_enable` defaults to `true`, and its implementation iterates **every installed Mason package** — not just `ensure_installed` — calling `vim.lsp.enable(<lspconfig_name>)` for each:

```lua
-- features/automatic_enable.lua
init = function()
  enabled_servers = {}
  _.each(enable_server, registry.get_installed_package_names())  -- ALL installed
  ...
```

The `jdtls` Mason package is installed (verified at `~/.local/share/nvim/mason/packages/jdtls`; it is also the binary `nvim-jdtls` launches). So `automatic_enable` calls `vim.lsp.enable('jdtls')` using nvim-lspconfig's default `lsp/jdtls.lua`, starting a **second** JDTLS on every Java buffer. When `nvim-jdtls`'s `on_attach` runs `jdtls.dap.setup_dap_main_class_configs()`, it counts two clients supporting `vscode.java.resolveMainClass` and warns.

The existing comment in `lua/config/lsp.lua` asserts jdtls is "naturally excluded from ensure_installed and automatic_enable" — the `automatic_enable` half is simply wrong.

## Goals / Non-Goals

**Goals:**
- Exactly one JDTLS client (the `nvim-jdtls` one) attaches per Java buffer.
- The `vscode.java.resolveMainClass` warning stops.
- All other configured servers continue to auto-enable exactly as before.
- The misleading comment is corrected to reflect the real `automatic_enable` semantics.

**Non-Goals:**
- Changing how `nvim-jdtls` is configured or how it locates the JDTLS binary.
- Uninstalling the Mason `jdtls` package (it is a legitimate dependency of `nvim-jdtls`).
- Touching `ensure_installed`, the `servers` table, or any other language server.

## Decisions

**Decision: Scope `automatic_enable` with an `exclude` list rather than any alternative.**

Change the setup call to:

```lua
require("mason-lspconfig").setup {
    ensure_installed = vim.tbl_keys(servers),
    automatic_enable = { exclude = { "jdtls" } },
}
```

Per `features/automatic_enable.lua`, when `automatic_enable` is a table with an `exclude` key, every installed server is auto-enabled *except* those in `exclude`. This keeps the existing "auto-enable everything installed" behavior for the real servers while carving out the one plugin-owned exception.

Alternatives considered:
- **`automatic_enable = false`** — disables auto-enable entirely, forcing us to manually `vim.lsp.enable` each server. More code, easy to drift out of sync with `ensure_installed`. Rejected.
- **`automatic_enable = { "lua_ls", "angularls", ... }`** (allowlist form) — a bare list enables *only* those named, which works but must be hand-maintained to mirror the `servers` table. Redundant with `ensure_installed`; more brittle. Rejected in favor of the `exclude` form.
- **`:MasonUninstall jdtls` + point `nvim-jdtls` at a non-Mason binary** — removes the trigger but discards the Mason-managed binary the config already depends on (`java-jdtls.lua:9`) and is more disruptive. Rejected.

**Decision: Rewrite the comment to state the real semantics.**

The corrected comment should note that `automatic_enable` enables *all* Mason-installed packages (not just `ensure_installed`), that `jdtls` is therefore excluded explicitly, and that Java is owned by `nvim-jdtls`.

## Risks / Trade-offs

- **Risk: `exclude` table shape/behavior differs across mason-lspconfig versions.** → Verified directly against the installed source (`features/automatic_enable.lua`, pinned commit `7adc933`): a table with `exclude` skips listed servers. If the plugin is later updated, re-verify against `:h mason-lspconfig` / the installed source.
- **Risk: another plugin-owned server is installed in Mason later and hits the same double-start.** → Out of scope now, but the `exclude` list is the exact place to add it; the corrected comment documents the pattern.
- **Trade-off: the exclusion is by lspconfig server name (`jdtls`), a string literal.** Acceptable — it mirrors how the rest of the config names servers, and there is only one such server.

## Migration Plan

1. Edit `lua/config/lsp.lua`: add `automatic_enable = { exclude = { "jdtls" } }` to the `mason-lspconfig.setup` call and correct the preceding comment.
2. Restart Neovim, open a `.java` file in a real project.
3. Verify with `:lua =vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))` that only one `jdtls` client is present, and that no `resolveMainClass` warning appears.

Rollback: revert the single-file edit; behavior returns to the prior (warning-emitting) state.

## Open Questions

None.
