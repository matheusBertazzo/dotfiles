# completion-engine

## Purpose

Defines the autocompletion engine for this Neovim configuration — its sources, snippet integration, LSP capability contribution, and keymaps — provided by `blink.cmp` with LuaSnip as the snippet engine.

## Requirements

### Requirement: Completion is provided by blink.cmp

The configuration SHALL provide autocompletion via `blink.cmp`, with default sources for LSP, filesystem paths, snippets, and buffer text. The legacy `nvim-cmp` stack (`nvim-cmp`, `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `cmp_luasnip`) SHALL be removed.

#### Scenario: LSP completion in a code buffer

- **WHEN** the user types in a buffer with an attached language server
- **THEN** blink.cmp offers LSP completion candidates

#### Scenario: Path and buffer completion

- **WHEN** the user types a filesystem path or a word present elsewhere in the buffer
- **THEN** blink.cmp offers path and buffer candidates respectively

#### Scenario: No nvim-cmp remnants

- **WHEN** the plugin set is loaded
- **THEN** none of `nvim-cmp`, `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, or `cmp_luasnip` are present

### Requirement: Existing LuaSnip snippets keep working

The configuration SHALL use LuaSnip as blink.cmp's snippet engine (`snippets = { preset = 'luasnip' }`) so the custom vscode-style snippets under `snippets/vscode/` (including choice nodes) continue to load and expand.

#### Scenario: Custom snippet expands

- **WHEN** the user triggers one of the custom snippets defined under `snippets/vscode/`
- **THEN** the snippet expands and tabstops behave as before

#### Scenario: friendly-snippets available

- **WHEN** a common snippet from `friendly-snippets` is triggered in a supported filetype
- **THEN** it expands via the LuaSnip engine through blink.cmp

#### Scenario: Choice node cycling

- **WHEN** the user is on a LuaSnip choice node (in insert or select mode) and presses the choice-cycle keys (`<C-l>`/`<C-h>`)
- **THEN** the active choice changes; and when no choice is active those keys fall through to their default (e.g. `<C-h>` deletes the previous character)

### Requirement: lazydev require-path completion via blink

The configuration SHALL register lazydev as a blink.cmp source so `require("...")` module-path completion is available in Lua buffers.

#### Scenario: Require path completes

- **WHEN** the user types a `require("...")` module path in a Lua buffer
- **THEN** lazydev module-path candidates appear in the blink.cmp menu

### Requirement: Completion keymaps are preserved

The configuration SHALL preserve the prior completion keymaps as closely as blink.cmp allows: select next/previous, confirm, hide/abort, scroll documentation, and snippet navigation.

#### Scenario: Confirm a completion

- **WHEN** a completion item is selected and the user presses the confirm key (`<CR>` or `<C-y>`)
- **THEN** the item is accepted

#### Scenario: Navigate the menu

- **WHEN** the completion menu is open and the user presses the next/previous keys (`<Tab>`/`<S-Tab>`)
- **THEN** the selection moves accordingly
