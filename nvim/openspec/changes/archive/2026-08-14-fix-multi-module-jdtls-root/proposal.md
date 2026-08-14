## Why

Opening Java files from a multi-module Maven/Gradle project (a reactor root whose submodules each have their own `pom.xml`) starts a **separate JDTLS server per module**, which triggers the repeated warning "Multiple LSP clients found that support vscode.java.resolveMainClass you should have at most one JDTLS server running". The root cause is `lua/plugins/java-jdtls.lua`: its `find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })` stops at the *nearest* ancestor containing any marker, so each module's `pom.xml` becomes its own `root_dir`, and `start_or_attach` cannot reuse a client across modules. This surfaces most visibly in Diffview because its changed-file list spans multiple modules, but it reproduces with plain buffers too.

## What Changes

- Change how `nvim-jdtls` resolves `root_dir` so that a multi-module Maven/Gradle project resolves to a **single reactor root** shared by all its modules, yielding exactly one JDTLS client for the whole project.
- The resolver walks up to the *outermost* ancestor that still looks like part of the same build (contiguous `pom.xml`/`build.gradle`), bounded by the VCS root (`.git`), instead of stopping at the first module-level build file.
- Because `workspace_dir` is derived from `basename(root_dir)`, this collapses the previous per-module JDTLS workspaces into a single workspace directory for the whole project.
- No change to JDTLS settings, DAP/test bundles, Java keymaps, or the Mason-managed binary path.

## Capabilities

### New Capabilities
- `java-lsp`: How the Java language server (`nvim-jdtls`) is started and attached in this configuration — specifically how it resolves a project's root directory so that a multi-module build maps to exactly one JDTLS server.

### Modified Capabilities
<!-- None. The existing `lsp-configuration` capability's jdtls scenario concerns mason-lspconfig double-enablement, a different mechanism, and is unchanged. -->

## Impact

- **Code**: `lua/plugins/java-jdtls.lua` (the `find_root` call inside `setup_jdtls`).
- **Behavior**: Exactly one JDTLS client attaches across all modules of a multi-module project; the `vscode.java.resolveMainClass` warning stops; cross-module navigation and classpath resolution work within one workspace; fewer JVMs.
- **Workspace**: JDTLS workspace directory becomes one per project root (e.g. `jdtls-workspace/<project>`) instead of one per module. Stale per-module workspace directories under `~/.local/share/nvim/jdtls-workspace/` are harmless and may be deleted.
- **No change** to the `servers` table, `mason-lspconfig` setup, `nvim-jdtls` settings/bundles/keymaps, or any other language server. No dependencies added or removed.
