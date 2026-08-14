## Context

Java in this config is driven by `nvim-jdtls` (`lua/plugins/java-jdtls.lua`). On every `FileType java`, `setup_jdtls()` computes a root with:

```lua
local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })
```

`jdtls.setup.find_root` walks **up** from the file's directory and returns the **first** (deepest / nearest) directory containing *any* listed marker. `workspace_dir` is then derived as `<home>/.local/share/nvim/jdtls-workspace/<basename(root_dir)>`, and `require("jdtls").start_or_attach(config)` reuses an existing client only when a client with the same `root_dir` already exists.

In a multi-module Maven reactor:

```
<project>/          pom.xml  .git  mvnw     ← reactor root
├── module-a/       pom.xml                 ← module (Example.java)
├── module-b/       pom.xml                 ← module
└── module-c/       pom.xml                 ← module
```

`find_root` stops at each module's own `pom.xml`, so files in different modules get different `root_dir` values (verified: `.../module-a`, `.../module-b`, `.../module-c`). `start_or_attach` therefore starts **one JDTLS per module**. The warning in `jdtls/util.lua:36-51` counts clients with `get_clients({ bufnr = nil })` — a **session-global** count — so as soon as two module servers exist, `setup_dap_main_class_configs()` reports "Multiple LSP clients ... resolveMainClass". Diffview makes this easy to hit because its changed-file list spans modules (when changed Java files live in more than one module), but plain buffers reproduce it identically. (The Diffview git-revision pane is *not* a cause: its buffer is named `diffview://…/.git/:0:/…`, for which `find_root` returns `nil` and `setup_jdtls` early-returns — verified via headless repro.)

JDTLS is designed to import a whole Maven reactor as a single workspace rooted at the reactor root. Fragmenting it per module not only emits the warning but also breaks cross-module navigation/classpath resolution and spawns N JVMs.

## Goals / Non-Goals

**Goals:**
- All modules of one multi-module project resolve to a single reactor `root_dir`, yielding exactly one JDTLS client per project.
- The `vscode.java.resolveMainClass` warning stops for multi-module projects.
- Single-module projects and projects with no build file behave as before (one root, or no server when no root).
- One JDTLS data workspace per project root, not per module.

**Non-Goals:**
- Changing JDTLS `settings`, DAP/test bundle wiring, Java keymaps, or the Mason binary path.
- Touching `lua/config/lsp.lua`, the `servers` table, or `mason-lspconfig` (the earlier `automatic_enable` exclusion is a different mechanism and stays as-is).
- Special-casing Diffview buffers (unnecessary — they already early-return via `find_root == nil`).
- Uninstalling or relocating the Mason `jdtls` package.

## Decisions

**Decision: Resolve to the outermost contiguous build root instead of the nearest build file.**

Replace the single `find_root(markers)` call with a resolver that ascends to the topmost ancestor that still belongs to the same build. The algorithm:

1. Find the nearest ancestor containing a module marker (`pom.xml` / `build.gradle` / `build.gradle.kts`) — the current behavior as a starting point.
2. From there, keep climbing while the *parent* directory also contains a module marker; the highest such directory is the reactor root.
3. Bound the climb by the VCS root: never ascend past a directory containing `.git` (and if a `.git` ancestor exists above the contiguous build dirs, prefer it as the reactor root, since a Maven reactor's top `pom.xml` and `.git` typically coincide).
4. If no build marker is found at all, fall back to the nearest `.git` ancestor; if none, return `nil` (no server).

Example: from `module-a/pom.xml`, the parent `<project>/` also has `pom.xml` (and `.git`), so the resolver returns `<project>/` — one root for all modules.

Alternatives considered:
- **`find_root({ ".git" })` only** — simplest one-liner; works here because `.git` sits at the reactor root. Rejected as the primary approach because it breaks for non-git checkouts and for git-submodule layouts (a nested `.git` would win), and it ignores the actual build structure. It remains the sensible *fallback* (step 4).
- **Detect `<modules>` in the top `pom.xml`** — most semantically precise (a reactor is exactly a pom declaring modules), but requires parsing XML at startup on every Java buffer. Rejected as overkill; contiguous-marker climbing plus the `.git` boundary captures the same intent cheaply.
- **Keep per-module roots, suppress the warning** — hides the symptom, keeps N JVMs and broken cross-module features. Rejected.

**Decision: Keep `workspace_dir = basename(root_dir)`.**

No change needed — once `root_dir` is the reactor root, the derived workspace is a single `jdtls-workspace/<project>` for the whole project, which is the desired outcome. Stale per-module workspace dirs from before the fix are inert and can be deleted manually.

**Decision: Do not add Diffview/buftype guards in this change.**

The headless repro shows Diffview's synthetic buffers resolve to `find_root == nil` and already early-return. Adding a buftype/URI guard would be dead code for this bug; it is noted as a possible future hardening but is out of scope.

## Risks / Trade-offs

- **Risk: the contiguous-climb picks a root that is too high** (e.g. unrelated sibling projects under one `.git` monorepo, each with independent builds not part of one reactor). → Mitigation: the climb only continues while *each successive parent* itself contains a build marker; an intermediate directory without `pom.xml`/`build.gradle` stops the ascent before an unrelated monorepo root. The `.git` boundary is an upper bound, not a forced target.
- **Risk: nested/aggregated builds where a subdirectory is itself a valid standalone reactor.** → Accepted: mapping such a project to its outermost reactor is the correct JDTLS behavior and matches how Maven/Gradle treat it.
- **Risk: `jdtls.setup.find_root` internals or marker semantics differ across nvim-jdtls versions.** → Mitigation: the resolver is built on the public `find_root` plus plain `vim.fs`/`uv.fs_stat` directory checks; verify against the installed `nvim-jdtls` when it is updated.
- **Trade-off: one large workspace instead of several small ones.** JDTLS indexes the whole reactor at once — slightly higher initial memory/index time, but this is the intended single-server model and is cheaper overall than N concurrent JVMs.

## Migration Plan

1. Edit `lua/plugins/java-jdtls.lua`: replace the `find_root(markers)` call in `setup_jdtls()` with the reactor-root resolver described above; keep the existing `if not root_dir or root_dir == "" then return end` guard.
2. Restart Neovim in a multi-module project.
3. Open Java files from two different modules, or open Diffview and select files spanning both modules.
4. Verify `:lua =#vim.lsp.get_clients({ name = 'jdtls' })` is `1`, that both clients' `config.root_dir` is the reactor root, and that `:messages` shows no `resolveMainClass` warning.
5. Optionally delete stale per-module workspace dirs under `~/.local/share/nvim/jdtls-workspace/`.

Rollback: revert the single-file edit; behavior returns to per-module roots.

## Open Questions

None.
