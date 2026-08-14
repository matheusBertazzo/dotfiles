## ADDED Requirements

### Requirement: JDTLS resolves a multi-module project to a single root

The configuration SHALL resolve the `nvim-jdtls` `root_dir` for a Java buffer to the *outermost* directory of its build — i.e. the reactor root of a multi-module Maven/Gradle project — rather than the nearest ancestor containing a build file. Concretely, starting from the buffer's file, the resolver SHALL ascend while consecutive ancestor directories continue to contain a build marker (`pom.xml` or `build.gradle`/`build.gradle.kts`) and SHALL treat the VCS root (`.git`) as the outer boundary, so that every module of the same project resolves to one shared `root_dir`.

#### Scenario: Files in different modules share one root

- **WHEN** two Java buffers are opened whose files live in different modules of the same multi-module project (each module having its own `pom.xml`, under a common reactor directory containing the top-level `pom.xml` and `.git`)
- **THEN** `nvim-jdtls` resolves the same `root_dir` (the reactor root) for both buffers
- **AND** exactly one JDTLS client is started for the project and both buffers attach to it

#### Scenario: No duplicate-server warning across modules

- **WHEN** Java buffers from more than one module of the same multi-module project are open in a session
- **THEN** no "Multiple LSP clients found that support vscode.java.resolveMainClass you should have at most one JDTLS server running" warning is emitted
- **AND** `#vim.lsp.get_clients({ name = 'jdtls' })` equals `1`

#### Scenario: Single-module project still resolves correctly

- **WHEN** a Java buffer is opened in a single-module project (one `pom.xml` or `build.gradle` at the project root)
- **THEN** `nvim-jdtls` resolves `root_dir` to that project root and starts exactly one JDTLS client

### Requirement: JDTLS is not started for buffers without a resolvable root

The configuration SHALL start or attach JDTLS only when a project root can be resolved for the buffer; when no root is found, it SHALL NOT start a JDTLS client.

#### Scenario: No root, no server

- **WHEN** a Java buffer has no ancestor directory containing a build marker or `.git`
- **THEN** no JDTLS client is started for that buffer

#### Scenario: One workspace per project root

- **WHEN** JDTLS is started for a resolved project root
- **THEN** its data workspace directory is derived from that single project root (one workspace per project), not one per module
