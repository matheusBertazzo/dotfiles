## MODIFIED Requirements

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
