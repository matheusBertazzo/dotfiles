## 1. Add blink.cmp plugin

- [ ] 1.1 Create `lua/plugins/blink.lua` with `Saghen/blink.cmp`, `version = '1.*'`, and dependencies `L3MON4D3/LuaSnip` + `rafamadriz/friendly-snippets`.
- [ ] 1.2 Configure `snippets = { preset = 'luasnip' }`.
- [ ] 1.3 Configure `sources.default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' }` and add `sources.providers.lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 }`.
- [ ] 1.4 Configure the `keymap` table to preserve prior behavior: `<Tab>`/`<S-Tab>` and `<Down>`/`<Up>` select next/prev; `<CR>` and `<C-y>` accept; `<C-e>` hide; `<C-u>`/`<C-d>` scroll docs; `<C-n>`/`<C-p>` snippet forward/backward; `<C-l>`/`<C-h>` custom LuaSnip choice change.
- [ ] 1.5 Enable blink's signature help (`signature = { enabled = true }`) or leave the existing `gs` → `vim.lsp.buf.signature_help` map; keep completion documentation window enabled.

## 2. Rewire capabilities and remove cmp

- [ ] 2.1 In `lua/config/lsp.lua`, change the capabilities line to `local capabilities = require('blink.cmp').get_lsp_capabilities()` (keep the `vim.lsp.config('*', { capabilities = capabilities })` broadcast).
- [ ] 2.2 Delete the entire `cmp.setup{...}` block (and `local cmp`/`local select_opts` locals) from `lua/config/lsp.lua`; keep the `luasnip.loaders.from_vscode` loader calls and `vim.opt.completeopt` if still desired.
- [ ] 2.3 Remove `hrsh7th/nvim-cmp`, `hrsh7th/cmp-nvim-lsp`, `hrsh7th/cmp-buffer`, `hrsh7th/cmp-path`, and `saadparwaiz1/cmp_luasnip` from `lua/plugins/nvim-lspconfig.lua` (keep `LuaSnip` and `friendly-snippets`).

## 3. Verification

- [ ] 3.1 `:Lazy sync` installs blink.cmp with prebuilt binaries and removes the cmp plugins; no startup errors.
- [ ] 3.2 Verify LSP completion: type in a code buffer with an attached server and confirm blink offers candidates; confirm `<CR>`/`<Tab>` behave as configured.
- [ ] 3.3 Verify capabilities still land: `:lua =vim.lsp.get_clients({name='lua_ls'})[1].config.capabilities.textDocument.completion.completionItem.snippetSupport` returns `true`.
- [ ] 3.4 Verify a custom snippet from `snippets/vscode/` expands (including a choice node, cycled via `<C-l>`/`<C-h>`).
- [ ] 3.5 Verify `require("...")` module-path completion appears in a Lua buffer (lazydev via blink).
- [ ] 3.6 Verify path and buffer completion both work.
