## ADDED Requirements

### Requirement: Parser branch is pinned to match the API in use

The nvim-treesitter plugin specification SHALL pin `branch = 'main'`, matching the `main`-branch rewrite API used by the setup (`ts.install`, `ts.get_installed`, `vim.treesitter.start`), so that plugin updates cannot silently switch to the incompatible `master` branch API.

#### Scenario: Spec declares the main branch

- **WHEN** the nvim-treesitter plugin spec is loaded
- **THEN** it declares `branch = 'main'`

#### Scenario: Update does not switch API

- **WHEN** the plugin manager updates plugins
- **THEN** nvim-treesitter remains on the `main` branch and the setup's `ts.install`/`vim.treesitter.start` calls continue to resolve

### Requirement: Filetype is mapped to TreeSitter language before use

The setup SHALL resolve a buffer's TreeSitter language via `vim.treesitter.language.get_lang(<filetype>)` before checking parser availability or installation, so that filetypes whose name differs from the parser name (e.g. `typescriptreact → tsx`, `sh → bash`) are handled correctly.

#### Scenario: Filetype differs from language name

- **WHEN** a buffer whose filetype differs from its TreeSitter language name is opened (e.g. `typescriptreact`)
- **THEN** the correct parser language (e.g. `tsx`) is resolved and used for availability/installation checks

#### Scenario: Filetype matches language name

- **WHEN** a buffer whose filetype equals its TreeSitter language name is opened (e.g. `lua`)
- **THEN** that language is resolved and highlighting starts as before

### Requirement: Highlighting starts after lazy installation

When a parser is not yet installed and is installed lazily on first open, the setup SHALL start TreeSitter for that buffer once the asynchronous installation completes, without requiring the user to reopen the buffer.

#### Scenario: First open of an uninstalled language

- **WHEN** a buffer is opened for a language whose parser is not yet installed
- **THEN** the parser is installed and TreeSitter highlighting starts for that buffer once installation finishes

#### Scenario: Already-installed language

- **WHEN** a buffer is opened for a language whose parser is already installed
- **THEN** TreeSitter highlighting starts immediately without reinstalling

### Requirement: TreeSitter textobjects are available

The configuration SHALL install and configure `nvim-treesitter-textobjects` (`main` branch) and provide keymaps to select TreeSitter textobjects (at minimum function and class, inner and outer).

#### Scenario: Select a function textobject

- **WHEN** the user triggers the "outer function" textobject in a supported buffer
- **THEN** the enclosing function region is selected

#### Scenario: Select a class textobject

- **WHEN** the user triggers the "inner class" textobject in a supported buffer
- **THEN** the inner class region is selected

### Requirement: Structural folding uses TreeSitter

The configuration SHALL enable TreeSitter-based folding using `vim.treesitter.foldexpr()` for buffers where TreeSitter is active, and files SHALL open unfolded by default.

#### Scenario: Folds follow code structure

- **WHEN** a buffer with an active TreeSitter parser is opened
- **THEN** folds are computed from the syntax tree via `vim.treesitter.foldexpr()`

#### Scenario: File opens unfolded

- **WHEN** a foldable buffer is first opened
- **THEN** its content is displayed unfolded (no regions collapsed on entry)
