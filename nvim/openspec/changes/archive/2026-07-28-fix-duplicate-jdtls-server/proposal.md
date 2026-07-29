## Why

Opening any `.java` file emits the warning "Multiple LSP clients found that support vscode.java.resolveMainClass you should have at most one JDTLS server running", repeatedly. Two JDTLS servers attach to every Java buffer: one started intentionally by `nvim-jdtls`, and a second one started by `mason-lspconfig`'s `automatic_enable`, which enables *every* Mason-installed server — including the installed `jdtls` package — independent of `ensure_installed`. Java is meant to be driven solely by `nvim-jdtls`, so the second server is redundant and breaks the DAP main-class resolution it warns about.

## What Changes

- Exclude `jdtls` from `mason-lspconfig`'s `automatic_enable` in `lua/config/lsp.lua`, so the Mason-installed `jdtls` package is no longer auto-enabled via `vim.lsp.enable`. `nvim-jdtls` (`lua/plugins/java-jdtls.lua`) becomes the sole owner of the Java language server.
- Correct the inaccurate comment in `lua/config/lsp.lua` that claims jdtls is "naturally excluded from ensure_installed and automatic_enable". Only the `ensure_installed` half is true; `automatic_enable` enables all installed packages regardless of `ensure_installed`, which is the root cause.
- All other configured servers continue to auto-enable unchanged.

## Capabilities

### New Capabilities
<!-- None. -->

### Modified Capabilities
- `lsp-configuration`: The "Installed servers are enabled natively" requirement changes — `automatic_enable` is scoped to exclude servers (specifically `jdtls`) that are owned by a separate plugin, so a Mason-installed package does not get double-started outside the `servers` table.

## Impact

- **Code**: `lua/config/lsp.lua` (the `mason-lspconfig.setup` call and its preceding comment).
- **Behavior**: Exactly one JDTLS client attaches per Java buffer; the `vscode.java.resolveMainClass` warning stops; `nvim-jdtls` DAP main-class configuration works as intended.
- **No change** to `ensure_installed`, to the `servers` table, to `nvim-jdtls` setup, or to any other language server.
- **Dependencies**: none added or removed. The Mason `jdtls` package stays installed (it is used by `nvim-jdtls` via `~/.local/share/nvim/mason/bin/jdtls`).
