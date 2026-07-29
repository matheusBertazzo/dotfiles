## 1. Add blink.cmp plugin

- [x] 1.1 Create `lua/plugins/blink.lua` with `Saghen/blink.cmp`, `version = '1.*'`, and dependencies `L3MON4D3/LuaSnip` + `rafamadriz/friendly-snippets`.
- [x] 1.2 Configure `snippets = { preset = 'luasnip' }`.
- [x] 1.3 Configure `sources.default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' }` and add `sources.providers.lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 }`.
- [x] 1.4 Configure the `keymap` table to preserve prior behavior: `<Tab>`/`<S-Tab>` and `<Down>`/`<Up>` select next/prev; `<CR>` and `<C-y>` accept; `<C-e>` hide; `<C-u>`/`<C-d>` scroll docs; `<C-n>`/`<C-p>` snippet forward/backward. LuaSnip choice change (`<C-l>`/`<C-h>`) is NOT in the blink keymap table — blink drops custom functions in select mode — but set as standalone `{i,s}` plain (non-expr) keymaps in `lua/config/lsp.lua`. They must not be expr mappings: `change_choice()` mutates the buffer, which textlock forbids under expr. When no choice is active they feed the key through (`nvim_feedkeys`, noremap) so `<C-h>` still backspaces.
- [x] 1.5 Enable blink's signature help (`signature = { enabled = true }`) or leave the existing `gs` → `vim.lsp.buf.signature_help` map; keep completion documentation window enabled.

## 2. Rewire capabilities and remove cmp

- [x] 2.1 In `lua/config/lsp.lua`, change the capabilities line to `local capabilities = require('blink.cmp').get_lsp_capabilities()` (keep the `vim.lsp.config('*', { capabilities = capabilities })` broadcast).
- [x] 2.2 Delete the entire `cmp.setup{...}` block (and `local cmp`/`local select_opts` locals) from `lua/config/lsp.lua`; keep the `luasnip.loaders.from_vscode` loader calls and `vim.opt.completeopt` if still desired.
- [x] 2.3 Remove `hrsh7th/nvim-cmp`, `hrsh7th/cmp-nvim-lsp`, `hrsh7th/cmp-buffer`, `hrsh7th/cmp-path`, and `saadparwaiz1/cmp_luasnip` from `lua/plugins/nvim-lspconfig.lua` (keep `LuaSnip` and `friendly-snippets`).

## 3. Verification

- [x] 3.1 `:Lazy sync` installs blink.cmp with prebuilt binaries and removes the cmp plugins; no startup errors.
- [x] 3.2 Verify LSP completion: type in a code buffer with an attached server and confirm blink offers candidates; confirm `<CR>`/`<Tab>` behave as configured.
- [x] 3.3 Verify capabilities still land: `:lua =vim.lsp.get_clients({name='lua_ls'})[1].config.capabilities.textDocument.completion.completionItem.snippetSupport` returns `true`.
- [x] 3.4 Verify a custom snippet from `snippets/vscode/` expands (including a choice node, cycled via `<C-l>`/`<C-h>`).
- [x] 3.5 Verify `require("...")` module-path completion appears in a Lua buffer (lazydev via blink).
- [x] 3.6 Verify path and buffer completion both work.
