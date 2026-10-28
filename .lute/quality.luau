const process = require "@std/process"
-- const fs = require "@std/fs"
-- const net = require "@std/net"

const cli = require "@batteries/cli"

const process_util = require "./lib/process_util"

const HELP_FLAG = "help"
const CHECK_ALL_FLAG = "all"
const FORMAT_FLAG = "format"
-- const TYPECHECK_FLAG = "typecheck"
const FIX_FLAG = "fix-all"
const FIX_FORMAT_FLAG = "fix-format"

const CI_FLAG = "ci"

-- const GLOBAL_TYPES_NET_PATH =
-- 	"https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/refs/heads/main/scripts/globalTypes.d.luau"
-- const GLOBAL_TYPES_FS_PATH = ".lute/globalTypes.d.luau"

const args = cli.parser()

args:add("plugins", "variadic", {})

args:add(HELP_FLAG, "flag", {
	help = "Show help.",
	aliases = { "h" },
})

args:add(CHECK_ALL_FLAG, "flag", {
	help = "Check all parts of code.",
})

args:add(FORMAT_FLAG, "flag", {
	help = "Run formatting with StyLua.",
})
-- TODO: typecheck support
-- args:add(TYPECHECK_FLAG, "flag", {
-- 	help = "Run typechecking with Roblox global types.",
-- })

args:add(FIX_FLAG, "flag", { help = "Fix all present issues." })
args:add(FIX_FORMAT_FLAG, "flag", { help = "Apply formatting changes." })

args:add(CI_FLAG, "flag", { help = "Use CI defaults, overrides the command." })
args:parse(process.args)

if args:has(HELP_FLAG) then
	args:help()
	process.exit(0)
end

if args:has(CI_FLAG) then
	args:parse { "quality", "--all" }
end

local exit_code = 0

const function update_code(with: number)
	if with ~= 0 and exit_code == 0 then
		exit_code = 1
	end
end

if args:has(FORMAT_FLAG) or args:has(CHECK_ALL_FLAG) then
	const stylua_args = { "stylua", "src", ".lute", "--respect-ignores" }
	table.insert(stylua_args, "--check")

	if args:has(FIX_FLAG) or args:has(FIX_FORMAT_FLAG) then
		table.remove(stylua_args, table.find(stylua_args, "--check"))
	end

	const stylua = process_util.exec_and_await(stylua_args, {
		stdio = "inherit",
	})

	update_code(stylua.exitcode)
end

-- TODO: typecheck support
-- if args:has(TYPECHECK_FLAG) then
-- 	do
-- 		const analyze_lute_args = { "luau-lsp", "analyze", ".lute" }
-- 	end

-- 	const response = net.request(GLOBAL_TYPES_NET_PATH)

-- 	if not response.ok then
-- 		update_code(1)
-- 	else
-- 		fs.writeStringToFile(GLOBAL_TYPES_FS_PATH, response.body)

-- 		const analyze_src_args = {
-- 			"luau-lsp",
-- 			"analyze",
-- 			"--defs",
-- 			".lute/globalTypes.d.luau",
-- 			"--sourcemap",
-- 			"sourcemap.json",
-- 			"--ignore",
-- 			"**/roblox_packages/**",
-- 			"src",
-- 		}

-- 		const src_analyze = process_util.exec_and_await(analyze_src_args, {
-- 			stdio = "inherit",
-- 		})

-- 		update_code(src_analyze.exitcode)
-- 	end
-- end

process.exit(exit_code)
