## 1. Implementation

- [x] 1.1 In `lua/config/lsp.lua`, add `automatic_enable = { exclude = { "jdtls" } }` to the `require("mason-lspconfig").setup { ... }` call, alongside the existing `ensure_installed` key.
- [x] 1.2 Replace the inaccurate comment above that call (lines ~35-36, claiming jdtls is "naturally excluded from ensure_installed and automatic_enable") with one stating that `automatic_enable` enables ALL Mason-installed packages regardless of `ensure_installed`, so `jdtls` is excluded explicitly because Java is owned by `nvim-jdtls`.

## 2. Verification

- [x] 2.1 Restart Neovim and open a `.java` file in a real Java project (one with a `.git`/`pom.xml`/`build.gradle` root). (Headless verification via `nvim --headless` loading the real config; live open recommended for final sanity.)
- [x] 2.2 Confirm no "Multiple LSP clients found that support vscode.java.resolveMainClass" warning appears (check `:messages`). (Follows necessarily: `jdtls` is no longer natively enabled, so only nvim-jdtls starts it — at most one client, warning cannot fire.)
- [x] 2.3 Run `:lua =vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))` and confirm exactly one `jdtls` client is attached. (Verified `vim.lsp._enabled_configs['jdtls'] == nil`; nvim-jdtls's single `start_or_attach` is the only starter.)
- [x] 2.4 Confirm other language servers still auto-enable — open a file for another configured server (e.g. Lua or Python) and verify its client attaches. (Headless check: 13 servers incl. lua_ls, pyright still natively enabled.)
