## 1. Pin parser branch

- [x] 1.1 In `lua/plugins/tree-sitter.lua`, add `branch = 'main'` to the nvim-treesitter plugin spec (keep `lazy = false` and `build = ':TSUpdate'`).

## 2. Fix the FileType autocmd (setup/tree-sitter.lua)

- [x] 2.1 Resolve the language with `local lang = vim.treesitter.language.get_lang(vim.bo.filetype) or vim.bo.filetype` and use `lang` (not `vim.bo.filetype`) for all `ts.get_available()` / `ts.get_installed()` checks.
- [x] 2.2 When `lang` is available but not installed, install it in the async-install completion callback; guard with `vim.api.nvim_buf_is_valid(buf)` and a filetype recheck. On completion: (a) clear Neovim's stale query cache with `vim.treesitter.query.get:clear()` under `pcall` — a runtime install does not change `runtimepath`, so the memoized nil highlight-query miss survives and the highlighter renders no colors until restart; (b) reload the unmodified buffer via `vim.api.nvim_buf_call(buf, function() vim.cmd('edit') end)` so a fresh highlighter reads the now-present query and repaints; fall back to `start()` if the buffer is modified.
- [x] 2.3 When `lang` is already installed, keep starting TreeSitter immediately (existing behavior), now keyed on `lang`.

## 3. Structural folding

- [x] 3.1 In the code path that starts TreeSitter for a buffer, set window-local `foldmethod = 'expr'` and `foldexpr = 'v:lua.vim.treesitter.foldexpr()'`.
- [x] 3.2 Ensure files open unfolded (set `vim.opt.foldlevelstart = 99`, or window-local `foldlevel = 99` on TS start).

## 4. Textobjects plugin

- [x] 4.1 Add a plugin spec for `nvim-treesitter/nvim-treesitter-textobjects` pinned to `branch = 'main'` (as a dependency of nvim-treesitter or its own file under `lua/plugins/`).
- [x] 4.2 Call `require('nvim-treesitter-textobjects').setup{}` (with `select = { lookahead = true }`).
- [x] 4.3 Add `{x, o}`-mode SELECT keymaps via `require('nvim-treesitter-textobjects.select').select_textobject(<query>, 'textobjects')`: `af`/`if` (`@function.outer`/`@function.inner`), `ac`/`ic` (`@class.outer`/`@class.inner`), `aa`/`ia` (`@parameter.outer`/`@parameter.inner`).
- [x] 4.4 Add `{n, x, o}`-mode MOVE keymaps via `require('nvim-treesitter-textobjects.move')`: `]f`/`[f` → `goto_next_start`/`goto_previous_start('@function.outer', 'textobjects')`; `]C`/`[C` → same for `@class.outer` (capitalized to preserve diff-mode `]c`/`[c`).

## 5. Verification

- [x] 5.1 Restart Neovim with no startup errors; run `:TSUpdate` and confirm parsers update on the `main` branch.
- [x] 5.2 Verify branch pin: `:Lazy` shows nvim-treesitter and nvim-treesitter-textobjects on `branch = main`.
- [x] 5.3 Verify filetype→lang mapping: open a `.tsx` (or `.jsx`/shell) file and confirm TreeSitter highlighting is active (`:lua =vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil` is `true`, or `:InspectTree` shows a tree).
- [x] 5.4 Verify start-after-install: with a not-yet-installed language, open a file of that type and confirm highlighting appears without reopening (may need a moment for install).
- [x] 5.5 Verify folding: open a code file, confirm `:set foldexpr?` shows the TreeSitter foldexpr, folds follow structure (`zc`/`zo` work), and the file opened unfolded.
- [x] 5.6 Verify SELECT: in a supported file, confirm `vaf` selects the function, `vic` selects the inner class, and `via` selects an argument.
- [x] 5.7 Verify MOVE: confirm `]f`/`[f` jump between functions and `]C`/`[C` jump between classes, while diff-mode `]c`/`[c` still works in a `:diffthis` split.
