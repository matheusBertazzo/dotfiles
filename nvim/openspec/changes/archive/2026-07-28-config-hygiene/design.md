## Context

Small modernization sweep on Neovim 0.11. Four independent, low-risk items. The only one with a behavior (keymap) change is dropping `mini.comment` for built-in commenting; the rest are API/dependency hygiene.

## Goals / Non-Goals

**Goals:**
- Remove the deprecated `vim.highlight.on_yank` call.
- Point Mason specs at the canonical `mason-org/*` org.
- Use Neovim built-in commenting instead of `mini.comment`.
- Provide icons through a single provider (`mini.icons`).

**Non-Goals:**
- Completion stack migration (separate `blink-cmp-migration` change).
- Fixing the disabled `mini.surround` / `mini.indentscope` conflicts.
- Any change to LSP or TreeSitter behavior.

## Decisions

### Decision: Built-in commenting replaces mini.comment

Remove `mini.comment` from both `lua/plugins/mini.lua` and its setup in `lua/config/mini.lua`; rely on Neovim's built-in `gc`/`gcc` (available since 0.10, driven by `commentstring`).

- **Why**: native, zero-dependency, standard keymaps.
- **Trade-off**: the current custom maps (`<leader>cc`, `<leader>cl`) go away in favor of `gc`/`gcc`. If a specific filetype lacks a correct `commentstring`, set it via ftplugin/autocmd (TreeSitter also supplies commentstring for many langs).

### Decision: mini.icons mock, drop nvim-web-devicons

Call `require('mini.icons').mock_nvim_web_devicons()` during icon setup so any `require('nvim-web-devicons')` resolves to the mini.icons shim, then remove the standalone `nvim-web-devicons` plugin spec.

- **Why**: one icon provider; plugins that hard-`require` devicons (e.g. nvim-tree) keep working through the mock.
- **Risk**: a consumer loads before the mock is installed → set up the mock early (with `mini.icons`), and verify nvim-tree/which-key still render icons. If a consumer proves order-sensitive, keep `nvim-web-devicons` as a lazy dep for that consumer only.

### Decision: mason-org rename is a spec-only edit

Change the owner in `lua/plugins/nvim-lspconfig.lua`. `lazy.nvim` treats it as the same plugin path change; a `:Lazy sync` updates the remote. No behavior change.

## Risks / Trade-offs

- **Icon mock ordering** → install the mock as part of mini setup that runs before UI plugins draw; verify nvim-tree icons.
- **commentstring gaps for niche filetypes** → rare; fixable per-filetype, and TreeSitter improves defaults.
- **Muscle memory for `<leader>cc`** → intentional; `gc`/`gcc` is the standard.

## Migration Plan

1. `vim.highlight.on_yank` → `vim.hl.on_yank`.
2. Mason specs → `mason-org/*`; `:Lazy sync`.
3. Remove `mini.comment` (plugin + setup); confirm `gcc`/`gc` work.
4. Add `mock_nvim_web_devicons()`; remove `nvim-web-devicons` spec; verify icons.
5. **Rollback**: revert per-item; all four are independent.

## Open Questions

- None blocking. If you actually prefer keeping `<leader>cc` as a comment map, we can bind it to `gcc` instead of dropping to defaults only.
