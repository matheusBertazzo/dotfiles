return {
	"mfussenegger/nvim-jdtls",
	ft = { "java" }, -- Only load this plugin when opening a Java file
	dependencies = {
		"mfussenegger/nvim-dap",
	},
	config = function()
		local home = os.getenv("HOME")
		local jdtls_bin = home .. "/.local/share/nvim/mason/bin/jdtls"

		local function setup_jdtls()
			local workspace_path = home .. "/.local/share/nvim/jdtls-workspace/"
			local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })

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
