## ADDED Requirements

### Requirement: Yank highlighting uses the non-deprecated API

The configuration SHALL highlight yanked text using `vim.hl.on_yank()` rather than the deprecated `vim.highlight.on_yank()`.

#### Scenario: Yank highlights without deprecation warning

- **WHEN** the user yanks text
- **THEN** the yanked region is briefly highlighted and no deprecation warning is emitted

### Requirement: Commenting uses Neovim built-in operators

The configuration SHALL rely on Neovim's built-in commenting (`gc` operator, `gcc` line toggle) and SHALL NOT depend on `mini.comment` for that behavior.

#### Scenario: Toggle a line comment

- **WHEN** the user presses `gcc` on a code line
- **THEN** the line's comment state toggles using the buffer's `commentstring`

#### Scenario: Comment a motion or selection

- **WHEN** the user applies `gc` over a motion or visual selection
- **THEN** the covered lines are commented/uncommented

### Requirement: Mason plugins reference the canonical org

The configuration SHALL reference the Mason plugins from the `mason-org/*` organization (`mason-org/mason.nvim`, `mason-org/mason-lspconfig.nvim`) rather than the transferred `williamboman/*` paths.

#### Scenario: Plugin specs use mason-org

- **WHEN** the plugin specifications are loaded
- **THEN** the Mason plugins are sourced from `mason-org/mason.nvim` and `mason-org/mason-lspconfig.nvim`

### Requirement: Icon provider is not duplicated

The configuration SHALL provide file/type icons through `mini.icons` (including its `nvim-web-devicons` compatibility mock) and SHALL NOT also load `nvim-web-devicons` solely as a redundant provider.

#### Scenario: Icons render through a single provider

- **WHEN** a UI component requests icons (e.g. which-key, nvim-tree)
- **THEN** icons are provided via `mini.icons` and no separate redundant `nvim-web-devicons` dependency is required for that purpose
