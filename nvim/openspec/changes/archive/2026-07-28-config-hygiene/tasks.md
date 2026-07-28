## 1. Deprecated API

- [x] 1.1 In `lua/config/auto-commands.lua`, replace `vim.highlight.on_yank()` with `vim.hl.on_yank()`.

## 2. Mason org rename

- [x] 2.1 In `lua/plugins/nvim-lspconfig.lua`, change `williamboman/mason.nvim` → `mason-org/mason.nvim` and `williamboman/mason-lspconfig.nvim` → `mason-org/mason-lspconfig.nvim`.
- [x] 2.2 Run `:Lazy sync` and confirm both plugins resolve from the new org with no errors.

## 3. Built-in commenting

- [x] 3.1 Remove the `mini.comment` setup block from `lua/config/mini.lua`.
- [x] 3.2 Remove `echasnovski/mini.comment` from `lua/plugins/mini.lua`.
- [x] 3.3 Confirm built-in `gcc` (toggle line) and `gc` (motion/visual) work in a code buffer.

## 4. Icon dedup

- [x] 4.1 Add `require('mini.icons').mock_nvim_web_devicons()` to the mini.icons setup so `require('nvim-web-devicons')` resolves to the mini.icons shim (ensure it runs before UI plugins draw).
- [x] 4.2 Remove the standalone `nvim-tree/nvim-web-devicons` dependency where it is only a redundant provider (e.g. `which-key.lua` deps), keeping it only if a consumer proves order-sensitive.
- [x] 4.3 Verify icons still render in nvim-tree and which-key.

## 5. Verification

- [x] 5.1 Restart Neovim: no startup errors, no deprecation warning on yank (test by yanking a line).
- [x] 5.2 `:checkhealth` / `:Lazy` shows mason from `mason-org`, `mini.comment` absent, and a single icon provider.
