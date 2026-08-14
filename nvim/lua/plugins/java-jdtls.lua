return {
	"mfussenegger/nvim-jdtls",
	ft = { "java" }, -- Only load this plugin when opening a Java file
	dependencies = {
		"mfussenegger/nvim-dap",
	},
	config = function()
		local home = os.getenv("HOME")
		local jdtls_bin = home .. "/.local/share/nvim/mason/bin/jdtls"

		-- Build files that mark a Maven/Gradle project directory (a "module" in a
		-- multi-module build). `.git` is treated separately, as the VCS boundary.
		local build_markers = { "pom.xml", "build.gradle", "build.gradle.kts" }

		local function dir_has_build_marker(dir)
			for _, marker in ipairs(build_markers) do
				if vim.uv.fs_stat(vim.fs.joinpath(dir, marker)) then
					return true
				end
			end
			return false
		end

		-- Resolve the *outermost* project directory for a Java file, so every module of
		-- a multi-module Maven/Gradle reactor maps to a single JDTLS root. nvim-jdtls's
		-- own find_root stops at the *nearest* module's build file, which starts one
		-- JDTLS server per module; because jdtls counts clients session-globally (see
		-- jdtls/util.lua), that emits the "Multiple LSP clients ... resolveMainClass"
		-- warning. We climb to the top of the contiguous build tree, never crossing the
		-- VCS root, and prefer the VCS root when it is itself the reactor.
		local function find_reactor_root(source)
			local jdtls_setup = require("jdtls.setup")
			local nearest_module = jdtls_setup.find_root(build_markers, source)
			local git_root = jdtls_setup.find_root({ ".git" }, source)

			-- No build file at all: fall back to the VCS root (may be nil -> no server).
			if not nearest_module then
				return git_root
			end

			-- Climb while each parent is still part of the same build, never crossing
			-- the VCS root (a nested .git marks a separate repo, e.g. a git submodule).
			local root = nearest_module
			while root ~= git_root do
				local parent = vim.fs.dirname(root)
				if not parent or parent == root or not dir_has_build_marker(parent) then
					break
				end
				root = parent
			end

			-- A Maven reactor's top pom.xml and .git usually coincide; when the VCS root
			-- is itself a project directory, treat it as the reactor root. An unrelated
			-- monorepo whose VCS root has no build file is left untouched.
			if git_root and dir_has_build_marker(git_root) then
				return git_root
			end
			return root
		end

		local function setup_jdtls()
			local workspace_path = home .. "/.local/share/nvim/jdtls-workspace/"
			local root_dir = find_reactor_root(vim.api.nvim_buf_get_name(0))

			-- If we can't find a root, we probably shouldn't start jdtls
			if not root_dir or root_dir == "" then
				return
			end

			local project_name = vim.fs.basename(root_dir)
			local workspace_dir = workspace_path .. project_name

			-- Capabilities from nvim-cmp
			local capabilities = {}
			local cmp_lsp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
			if cmp_lsp_ok then
				capabilities = cmp_lsp.default_capabilities()
			end

			local config = {
				cmd = {
					jdtls_bin,
					"-data", workspace_dir,
				},
				root_dir = root_dir,
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					-- Java-specific keymaps. Standard LSP ones are handled in lua/config/lsp.lua
					local map = function(keys, func, desc)
						vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'Java: ' .. desc })
					end

					map('<leader>jo', require('jdtls').organize_imports, '[J]ava [O]rganize Imports')
					map('<leader>jv', require('jdtls').extract_variable, '[J]ava Extract [V]ariable')
					map('<leader>jc', require('jdtls').extract_constant, '[J]ava Extract [C]onstant')
					map('<leader>jm', require('jdtls').extract_method, '[J]ava Extract [M]ethod')

					-- Initialize debug session if nvim-dap is available
					local status_ok, jdtls_dap = pcall(require, "jdtls.dap")
					if status_ok then
						jdtls_dap.setup_dap_main_class_configs()
					end
				end,

				settings = {
					java = {
						signatureHelp = { enabled = true },
						contentProvider = { preferred = "fernflower" },
						completion = {
							favoriteStaticMembers = {
								"org.hamcrest.MatcherAssert.assertThat",
								"org.hamcrest.Matchers.*",
								"org.hamcrest.CoreMatchers.*",
								"org.junit.jupiter.api.Assertions.*",
								"java.util.Objects.requireNonNull",
								"java.util.Objects.requireNonNullElse",
								"org.mockito.Mockito.*",
							},
							filteredTypes = {
								"com.sun.*",
								"io.micrometer.shaded.*",
								"java.awt.*",
								"jdk.*",
								"sun.*",
							},
						},
						sources = {
							organizeImports = {
								starThreshold = 9999,
								staticStarThreshold = 9999,
							},
						},
						codeGeneration = {
							toString = {
								template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
							},
							useBlocks = true,
						},
					},
				},
				init_options = {
					bundles = {},
				},
			}

			-- Bundles for Debug/Test
			local bundles = vim.fn.glob(
				home ..
				"/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
				true,
				true
			)

			local test_bundles = vim.fn.glob(
				home .. "/.local/share/nvim/mason/packages/java-test/extension/server/*.jar",
				true,
				true
			)

			vim.list_extend(bundles, test_bundles)
			config.init_options.bundles = bundles

			-- Start or Attach the server
			require("jdtls").start_or_attach(config)
		end

		-- Ensure setup_jdtls is called for every Java file
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "java",
			callback = setup_jdtls,
		})

		-- Manually trigger for the first file if it's already open
		if vim.bo.filetype == "java" then
			setup_jdtls()
		end
	end,
}
