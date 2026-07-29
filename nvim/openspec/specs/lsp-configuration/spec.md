# lsp-configuration

## Purpose

Defines how language servers are configured, given client capabilities, and enabled in this Neovim configuration (targeting Neovim 0.11's native `vim.lsp.config` / `vim.lsp.enable` API), plus the Lua development ergonomics and diagnostic navigation keymaps that depend on that setup.

## Requirements

### Requirement: Client capabilities broadcast to all servers

The configuration SHALL construct client capabilities from `require('blink.cmp').get_lsp_capabilities()` and broadcast them to every language server using the Neovim 0.11 native `vim.lsp.config('*', { capabilities = ... })` mechanism, so that all servers receive the enhanced capabilities (including LSP snippet support and completion-item resolve).

#### Scenario: Capabilities reach an active server

- **WHEN** a language server (e.g. `lua_ls`) attaches to a buffer
- **THEN** the attached client's `config.capabilities.textDocument.completion.completionItem.snippetSupport` is `true`

#### Scenario: No reliance on the removed handlers API

- **WHEN** the LSP configuration is loaded
- **THEN** it does not pass a `handlers` table to `mason-lspconfig.setup` and does not depend on that API to apply capabilities

### Requirement: Per-server settings are effective

The configuration SHALL apply per-server settings from a `servers` table via `vim.lsp.config(<name>, <config>)` for each entry, so that custom settings actually take effect at server attach time. Server-specific settings SHALL override, and capability defaults from the `'*'` config SHALL be merged into, the resolved configuration.

#### Scenario: Custom server setting takes effect

- **WHEN** a server in the `servers` table declares a non-default setting and attaches to a buffer
- **THEN** the running client reflects that setting rather than the nvim-lspconfig default

#### Scenario: Servers without overrides still receive capabilities

- **WHEN** a server is listed with an empty override table
- **THEN** it is still enabled and still receives the broadcast client capabilities

### Requirement: Installed servers are enabled natively

The configuration SHALL install the servers listed in the `servers` table via `mason-lspconfig`'s `ensure_installed` and rely on its `automatic_enable` behavior to enable them through `vim.lsp.enable`, without calling the `require('lspconfig')` framework for setup. Because `automatic_enable` enables every Mason-installed package regardless of `ensure_installed`, the configuration SHALL scope `automatic_enable` to exclude any server that is owned by a separate plugin — specifically `jdtls`, which is driven by `nvim-jdtls` — so that a Mason-installed package is not auto-enabled outside the `servers` table.

#### Scenario: Configured servers start

- **WHEN** a buffer with a filetype handled by a configured server is opened
- **THEN** the corresponding server is installed (if missing) and attaches to the buffer

#### Scenario: Config precedes enablement

- **WHEN** the LSP module finishes loading
- **THEN** all `vim.lsp.config` calls have been made before `mason-lspconfig.setup` triggers enablement

#### Scenario: Plugin-owned server is not double-enabled

- **WHEN** a `.java` buffer is opened and the `jdtls` package is installed in Mason
- **THEN** `mason-lspconfig`'s `automatic_enable` does not call `vim.lsp.enable('jdtls')`, and exactly one JDTLS client — the one started by `nvim-jdtls` — attaches to the buffer
- **AND** no "Multiple LSP clients found that support vscode.java.resolveMainClass" warning is emitted

### Requirement: Lua development globals and types come from lazydev

The configuration SHALL rely on `lazydev.nvim` to provide the Neovim `vim` global and `vim.*` runtime types for Lua buffers, and SHALL NOT hardcode `lua_ls` `diagnostics.globals = {'vim'}`.

#### Scenario: No undefined-global warning for vim

- **WHEN** a Lua file in the configuration is opened
- **THEN** `lua_ls` does not report an "undefined global `vim`" diagnostic

#### Scenario: Neovim API completes

- **WHEN** the user types `vim.api.nvim_` in a Lua buffer
- **THEN** completion candidates for the Neovim API are offered

### Requirement: Diagnostic navigation uses non-deprecated API

The configuration SHALL navigate diagnostics using `vim.diagnostic.jump({ count = ... })` rather than the deprecated `vim.diagnostic.goto_prev()` / `vim.diagnostic.goto_next()` functions.

#### Scenario: Jump to next diagnostic

- **WHEN** the user presses the "next diagnostic" keymap
- **THEN** the cursor moves to the next diagnostic using `vim.diagnostic.jump` and no deprecation warning is emitted

#### Scenario: Jump to previous diagnostic

- **WHEN** the user presses the "previous diagnostic" keymap
- **THEN** the cursor moves to the previous diagnostic using `vim.diagnostic.jump`
