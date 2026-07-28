## Why

The config uses nvim-treesitter's **`main`-branch rewrite** API (`ts.install`, `vim.treesitter.start()` in `lua/setup/tree-sitter.lua`), but the plugin spec in `lua/plugins/tree-sitter.lua` does not pin `branch = 'main'`. The lockfile currently sits on `main` only incidentally; nvim-treesitter's default branch is still `master`, whose API is the entirely different `require('nvim-treesitter.configs').setup{}`. With `checker.enabled = true` surfacing updates constantly, a `:Lazy update` could move the plugin back to `master` and break every call in the setup at once.

There are also two correctness bugs in the FileType autocmd, and — because the `main` branch made them opt-in — highlighting-adjacent features (textobjects, structural folding) are silently absent.

## What Changes

- **Pin `branch = 'main'`** in `lua/plugins/tree-sitter.lua` so the spec matches the API actually in use.
- **Fix the `filetype ≠ language` bug**: `lua/setup/tree-sitter.lua` compares `vim.bo.filetype` directly against TreeSitter language names, which misses cases like `typescriptreact → tsx` and `sh → bash`. Resolve the language via `vim.treesitter.language.get_lang(filetype)` before checking availability/installation.
- **Fix "install but don't start"**: when a language is installed lazily on first open, highlighting currently does not start until the buffer is reopened (the install is async). Start TreeSitter once the async install completes.
- **Add textobjects** via the `nvim-treesitter-textobjects` plugin (`main` branch) — select/move/swap by function, class, parameter — with keymaps.
- **Add TreeSitter folding** using `vim.treesitter.foldexpr()` (built into Neovim core), enabled per-buffer when TreeSitter starts, with files opening unfolded.
- Out of scope: TreeSitter-based **indentation** (experimental on the `main` branch; deliberately excluded).

## Capabilities

### New Capabilities
- `treesitter-configuration`: How TreeSitter parsers are pinned, installed, and started per filetype, and the editing features layered on top (textobjects and structural folding).

### Modified Capabilities
<!-- None — no existing TreeSitter spec in openspec/specs/. -->

## Impact

- **Code**: `lua/plugins/tree-sitter.lua` (branch pin), `lua/setup/tree-sitter.lua` (lang mapping, start-after-install, fold enablement). New `lua/plugins/tree-sitter-textobjects.lua` (or an extension of the existing spec) and textobjects setup/keymaps.
- **Dependencies**: Adds `nvim-treesitter/nvim-treesitter-textobjects` (`main` branch). No removals. Folding uses Neovim core (`vim.treesitter.foldexpr`), no new dependency.
- **Behavior**: Consistent parser branch; correct highlighting for JSX/TSX/shell and other filetype≠lang cases; highlighting starts immediately on first open of a new language; textobject motions and structural folds available.
- **Out of scope**: LSP (already handled in the archived `lsp-refactor` change); TreeSitter indentation.
