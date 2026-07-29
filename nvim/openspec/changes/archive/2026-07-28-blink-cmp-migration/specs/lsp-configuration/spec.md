## MODIFIED Requirements

### Requirement: Client capabilities broadcast to all servers

The configuration SHALL construct client capabilities from `require('blink.cmp').get_lsp_capabilities()` and broadcast them to every language server using the Neovim 0.11 native `vim.lsp.config('*', { capabilities = ... })` mechanism, so that all servers receive the enhanced capabilities (including LSP snippet support and completion-item resolve).

#### Scenario: Capabilities reach an active server

- **WHEN** a language server (e.g. `lua_ls`) attaches to a buffer
- **THEN** the attached client's `config.capabilities.textDocument.completion.completionItem.snippetSupport` is `true`

#### Scenario: No reliance on the removed handlers API

- **WHEN** the LSP configuration is loaded
- **THEN** it does not pass a `handlers` table to `mason-lspconfig.setup` and does not depend on that API to apply capabilities

## REMOVED Requirements

### Requirement: lazydev completion source is active in nvim-cmp

**Reason**: nvim-cmp is removed in favor of blink.cmp; lazydev `require`-path completion is now provided through blink's lazydev source.

**Migration**: See the `completion-engine` capability's "lazydev require-path completion via blink" requirement.
