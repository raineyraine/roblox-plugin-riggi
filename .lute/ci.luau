const process = require "@std/process"

const cli = require "@batteries/cli"
const rt = require "@batteries/richterm"

const args = cli.parser()

const function exec_and_await(args: { string }, options: process.ProcessRunOptions?): process.ProcessResult
	print(rt.blue(rt.dim "$ " .. table.concat(args, " ")))
	return process.run(args, options)
end

args:add("help", "flag", {
	help = "Show help.",
	aliases = { "h" },
})

args:add("fix", "flag", {
	help = "Fix changes",
	aliases = { "f" },
})

args:parse(process.args)

if args:has "help" then
	args:help()
	process.exit(0)
end

const stylua_args = { "stylua", "src", ".lute", "--respect-ignores" }
if not args:has "fix" then
	table.insert(stylua_args, "--check")
end

exec_and_await(stylua_args, {
	stdio = "inherit",
})
