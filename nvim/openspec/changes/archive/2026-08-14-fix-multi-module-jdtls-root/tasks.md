## 1. Implementation

- [x] 1.1 In `lua/plugins/java-jdtls.lua`, add a local reactor-root resolver (used by `setup_jdtls`) that: (a) finds the nearest ancestor with a module marker (`pom.xml` / `build.gradle` / `build.gradle.kts`) via `require("jdtls.setup").find_root`, (b) climbs while the parent directory also contains a module marker, (c) bounds the climb at the nearest `.git` ancestor and prefers it as the reactor root when present, and (d) falls back to the nearest `.git` ancestor, else `nil`.
- [x] 1.2 Replace the existing `find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })` call in `setup_jdtls` with the new resolver, keeping the existing `if not root_dir or root_dir == "" then return end` early-return guard.
- [x] 1.3 Confirm `workspace_dir = workspace_path .. project_name` (where `project_name = vim.fs.basename(root_dir)`) is unchanged, so the workspace is derived from the single resolved reactor root.
- [x] 1.4 Add a brief comment explaining why the outermost contiguous build root is used (multi-module Maven reactors must map to one JDTLS server; session-global client count in `jdtls/util.lua` otherwise warns).

## 2. Verification

- [x] 2.1 Restart Neovim in a multi-module Maven project and open a Java file under one module and another under a different module (or open Diffview and select files spanning both modules).
- [x] 2.2 Run `:lua =#vim.lsp.get_clients({ name = 'jdtls' })` and confirm it is `1`.
- [x] 2.3 Run `:lua =vim.lsp.get_clients({ name = 'jdtls' })[1].config.root_dir` and confirm it is the reactor root (not a module subdirectory).
- [x] 2.4 Check `:messages` and confirm no "Multiple LSP clients found that support vscode.java.resolveMainClass" warning appears.
- [x] 2.5 Verify a single-module project still resolves to its own root and starts exactly one client (regression check).
- [x] 2.6 Optionally remove stale per-module workspace directories under `~/.local/share/nvim/jdtls-workspace/`.
