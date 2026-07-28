## 1. Pin parser branch

- [ ] 1.1 In `lua/plugins/tree-sitter.lua`, add `branch = 'main'` to the nvim-treesitter plugin spec (keep `lazy = false` and `build = ':TSUpdate'`).

## 2. Fix the FileType autocmd (setup/tree-sitter.lua)

- [ ] 2.1 Resolve the language with `local lang = vim.treesitter.language.get_lang(vim.bo.filetype) or vim.bo.filetype` and use `lang` (not `vim.bo.filetype`) for all `ts.get_available()` / `ts.get_installed()` checks.
- [ ] 2.2 When `lang` is available but not installed, install it and start TreeSitter for the buffer in the async-install completion callback; guard with `vim.api.nvim_buf_is_valid(buf)` and a filetype recheck so it does not start on a stale/closed buffer.
- [ ] 2.3 When `lang` is already installed, keep starting TreeSitter immediately (existing behavior), now keyed on `lang`.

## 3. Structural folding

- [ ] 3.1 In the code path that starts TreeSitter for a buffer, set window-local `foldmethod = 'expr'` and `foldexpr = 'v:lua.vim.treesitter.foldexpr()'`.
- [ ] 3.2 Ensure files open unfolded (set `vim.opt.foldlevelstart = 99`, or window-local `foldlevel = 99` on TS start).

## 4. Textobjects plugin

- [ ] 4.1 Add a plugin spec for `nvim-treesitter/nvim-treesitter-textobjects` pinned to `branch = 'main'` (as a dependency of nvim-treesitter or its own file under `lua/plugins/`).
- [ ] 4.2 Call `require('nvim-treesitter-textobjects').setup{}` (with `select = { lookahead = true }`).
- [ ] 4.3 Add `{x, o}`-mode select keymaps for at least function and class, inner and outer (`af`/`if`, `ac`/`ic`) using `require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')` and the corresponding queries.

## 5. Verification

- [ ] 5.1 Restart Neovim with no startup errors; run `:TSUpdate` and confirm parsers update on the `main` branch.
- [ ] 5.2 Verify branch pin: `:Lazy` shows nvim-treesitter and nvim-treesitter-textobjects on `branch = main`.
- [ ] 5.3 Verify filetype→lang mapping: open a `.tsx` (or `.jsx`/shell) file and confirm TreeSitter highlighting is active (`:lua =vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil` is `true`, or `:InspectTree` shows a tree).
- [ ] 5.4 Verify start-after-install: with a not-yet-installed language, open a file of that type and confirm highlighting appears without reopening (may need a moment for install).
- [ ] 5.5 Verify folding: open a code file, confirm `:set foldexpr?` shows the TreeSitter foldexpr, folds follow structure (`zc`/`zo` work), and the file opened unfolded.
- [ ] 5.6 Verify textobjects: in a function, confirm `vaf` selects the function and `vic` selects the inner class in a supported language.
