## Context

The config targets Neovim 0.11.5 and uses nvim-treesitter's `main`-branch rewrite. `lua/setup/tree-sitter.lua` calls `ts.install({...})`, iterates `ts.get_available()`/`ts.get_installed()`, and starts highlighting via `vim.treesitter.start()` in a `FileType` autocmd. `lua/plugins/tree-sitter.lua` declares the plugin with `lazy = false` and `build = ':TSUpdate'` but **no `branch`**. The lockfile currently pins `main` incidentally; nvim-treesitter's default branch is `master`, whose API is incompatible.

Confirmed facts:
- `vim.treesitter.foldexpr` exists in Neovim core (no plugin needed for folding).
- `nvim-treesitter-textobjects` is **not currently installed** — adding it is a new dependency.
- The current FileType autocmd uses `vim.bo.filetype` as the language key and calls `ts.install({lang})` (async) without a completion callback to start highlighting.

## Goals / Non-Goals

**Goals:**
- Make the plugin spec's branch match the API in use (`main`).
- Correctly map filetype → TreeSitter language before availability/install checks.
- Start highlighting immediately after a lazy async install.
- Add textobjects (function/class/parameter) with keymaps.
- Add structural folding via core `vim.treesitter.foldexpr()`, files opening unfolded.

**Non-Goals:**
- TreeSitter indentation (experimental on `main`; excluded).
- Reworking the parser install list.
- Any LSP changes (handled by the archived `lsp-refactor`).

## Decisions

### Decision: Pin `branch = 'main'` in the plugin spec

Add `branch = 'main'` to `lua/plugins/tree-sitter.lua`.

- **Why**: the setup depends on the `main` API; leaving the branch implicit means a `:Lazy update` follows the repo default (`master`) and breaks everything.
- **Alternative considered**: migrate back to the `master`/`configs.setup` API. Rejected — `main` is the forward direction and the setup is already written for it.

### Decision: Resolve language via `vim.treesitter.language.get_lang(filetype)`

In the FileType autocmd, compute `local lang = vim.treesitter.language.get_lang(vim.bo.filetype) or vim.bo.filetype`, then check `ts.get_available()`/`ts.get_installed()` and start/install against `lang`.

- **Why**: `filetype` is not always the parser name (`typescriptreact→tsx`, `sh→bash`); the current direct comparison silently skips those buffers.
- **Alternative considered**: a hand-maintained filetype→lang table. Rejected — `get_lang` is the built-in, always-current mapping.

### Decision: Start highlighting after async install completes

When `lang` is available but not installed, call `ts.install({ lang })` and start TreeSitter in its completion callback (e.g. `ts.install({ lang }):await(...)` or the install API's callback), guarded to the originating buffer if still valid.

- **Why**: the install is asynchronous; without a callback, the first open of a new language shows no highlighting until reopen.
- **Risk**: buffer may be gone by completion — guard with `vim.api.nvim_buf_is_valid` and only start if the current filetype still matches.

### Decision: Folding via core `vim.treesitter.foldexpr()`, set per-buffer on start

Where TreeSitter starts for a buffer, set `vim.wo.foldmethod = 'expr'` and `vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'`, and set `vim.opt.foldlevelstart = 99` (or per-window `foldlevel`) so files open unfolded.

- **Why**: core foldexpr needs no plugin; setting it only where TreeSitter is active avoids breaking non-TS buffers.
- **Alternative considered**: global `foldexpr`. Rejected — would apply to buffers with no parser.

### Decision: textobjects via `nvim-treesitter-textobjects` (`main` branch)

Add the plugin pinned to `branch = 'main'`, call its `setup{}`, and define select keymaps in `{x, o}` mode using `require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')` etc. Start with function/class (inner+outer); parameter/swap/move optional.

- **Why**: on `main`, textobjects is a separate plugin with its own `main` API distinct from the `master` module system.
- **Risk**: version drift between nvim-treesitter and textobjects `main` branches — pin both to `main` and update together.

## Risks / Trade-offs

- **textobjects `main` API churn** → pin `branch = 'main'`, keep keymaps minimal, update in lockstep with nvim-treesitter.
- **Fold settings leaking into non-TS buffers** → only set fold options in the same code path that starts TreeSitter.
- **Async-install callback firing after buffer closed** → guard with buffer validity + filetype recheck.
- **`foldlevelstart` is global** → acceptable; alternatively set window-local `foldlevel = 99` on TS start.

## Migration Plan

1. Add `branch = 'main'` to `lua/plugins/tree-sitter.lua`.
2. Add the textobjects plugin spec (`branch = 'main'`).
3. Rewrite the FileType autocmd in `lua/setup/tree-sitter.lua`: filetype→lang mapping, start-after-install callback, fold enablement on start.
4. Add textobjects `setup{}` + keymaps.
5. Restart Neovim; run `:TSUpdate`; verify highlighting on a `tsx`/`sh` file, fold behavior, and a textobject motion.
6. **Rollback**: revert the two files and drop the textobjects plugin spec; the prior setup still functions (on the incidentally-pinned `main` lock).

## Open Questions

- Which textobject keymaps beyond `af/if/ac/ic` do you want (parameter `aa/ia`, swap-parameter, move-to-next-function)? Default: start with function/class only; add more later.
