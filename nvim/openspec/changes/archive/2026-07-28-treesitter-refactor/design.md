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

### Decision: After async install, clear the query cache, then reload the buffer

When `lang` is available but not installed, call `ts.install({ lang }):await(vim.schedule_wrap(...))`. In the callback: (1) clear Neovim's memoized query cache via `vim.treesitter.query.get:clear()` (under `pcall`), then (2) reload the unmodified buffer via `vim.api.nvim_buf_call(buf, function() vim.cmd('edit') end)`.

- **Root cause (verified)**: `vim.treesitter.query.get(lang, 'highlights')` returns `nil` on a miss and is memoized. Neovim only invalidates that cache from its `nvim.treesitter.query_cache_reset` autocmd, which fires on `OptionSet runtimepath`. A runtime parser install writes the query files into a directory that is *already* on `runtimepath`, so rtp never changes and the cached `nil` miss survives. The highlighter then attaches (`highlighter.active[buf]` is non-nil) but has no highlights query → the buffer renders as plain white text. Only a full restart (fresh cache) fixed it — which is why an in-session `:edit` reload alone did not. Confirmed: `query.get` stays `nil` after install, and `vim.treesitter.query.get:clear()` restores a real Query object.
- **Why the rtp nudge does not work**: assigning `runtimepath` to its current value does not fire `OptionSet` (Neovim fires it only on an actual value change), so it does not trigger the reset. The direct `get:clear()` — exactly what Neovim's own reset autocmd calls — is used instead, guarded by `pcall`.
- **Why still reload the buffer**: after clearing the cache, re-`:edit` on the unmodified buffer re-runs this handler on the "already installed" path, creating a fresh highlighter that reads the now-present query and repainting the buffer wholesale (identical to reopening the file). End-to-end test with a force-poisoned cache ends with `hl_active = true` and `query_present = true`.
- **Risk**: cannot safely reload a modified buffer — guard on `vim.bo[buf].modified` and fall back to `start()`. `get:clear()` is not a documented public API — call under `pcall`. Guard on buffer validity + filetype recheck for the stale/reused case.

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

- Resolved: textobjects scope is Tier 1 + 2 — SELECT `af/if`, `ac/ic`, `aa/ia`; MOVE `]f/[f` (function) and `]C/[C` (class, capitalized to preserve diff-mode `]c/[c`). Swap and LSP-interop deferred.
