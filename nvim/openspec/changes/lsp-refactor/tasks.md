## 1. Capabilities and server config

- [ ] 1.1 In `lua/config/lsp.lua`, set `local capabilities = require('cmp_nvim_lsp').default_capabilities()` (drop the manual `make_client_capabilities` + `tbl_deep_extend` dance, since `default_capabilities` already extends the base).
- [ ] 1.2 Keep the `servers` table; leave `lua_ls = {}` (no hardcoded `diagnostics.globals`); retain the other server entries.
- [ ] 1.3 Broadcast capabilities once via `vim.lsp.config('*', { capabilities = capabilities })`.
- [ ] 1.4 Apply per-server overrides in a loop: `for name, cfg in pairs(servers) do vim.lsp.config(name, cfg) end`.

## 2. Enablement via mason-lspconfig

- [ ] 2.1 Ensure all `vim.lsp.config(...)` calls run BEFORE `mason-lspconfig.setup(...)`.
- [ ] 2.2 Reduce `mason-lspconfig.setup` to `{ ensure_installed = vim.tbl_keys(servers) }` — remove the `handlers` closure entirely.
- [ ] 2.3 Remove the `require('lspconfig')[server_name].setup(...)` call and any remaining references to the `lspconfig` framework in this file.
- [ ] 2.4 Confirm `jdtls` is still excluded from this path (Java remains driven by `lua/plugins/java-jdtls.lua`); it is not in the `servers` table, so no special-case is needed.

## 3. Lua completion source

- [ ] 3.1 Add `{ name = "lazydev", group_index = 0 }` to the nvim-cmp `sources` list in `lua/config/lsp.lua`.

## 4. Diagnostic keymaps

- [ ] 4.1 Replace the `[d` keymap with a callback using `vim.diagnostic.jump({ count = -1 })`.
- [ ] 4.2 Replace the `]d` keymap with a callback using `vim.diagnostic.jump({ count = 1 })`.

## 5. Verification

- [ ] 5.1 Reload Neovim (`:Lazy reload` / restart) with no startup errors and no deprecation warnings for diagnostic jumps.
- [ ] 5.2 Verify capabilities land: open a file, run `:lua =vim.lsp.get_clients({name='lua_ls'})[1].config.capabilities.textDocument.completion.completionItem.snippetSupport` and confirm it returns `true`.
- [ ] 5.3 Verify Lua ergonomics: open a `.lua` file, confirm no "undefined global `vim`" diagnostic and that `vim.api.nvim_` offers completions.
- [ ] 5.4 Verify a per-server setting is effective: add a temporary distinctive setting to one server in the `servers` table, reload, confirm it appears on the running client via `:lua =vim.lsp.get_clients({name='<server>'})[1].config.settings`, then remove the temporary setting.
- [ ] 5.5 Verify `require("...")` module-path completion appears in a Lua buffer (lazydev source active).

## 6. Optional (deferred by default)

- [ ] 6.1 Extract `lua/config/utils/lsp-capabilities.lua` returning `require('cmp_nvim_lsp').default_capabilities()` and consume it in both `lua/config/lsp.lua` and `lua/plugins/java-jdtls.lua` (lines 24-28) to remove duplication.
