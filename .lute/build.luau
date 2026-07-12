--!strict

const process = require "@lute/process"
const lute_fs = require "@lute/fs"

const cli = require "@batteries/cli"
const rt = require "@batteries/richterm"

const build_plugin = require "./lib/build-plugin"

const args = cli.parser()
args:add("install", "flag", {
	help = "Install to the Studio plugin folder automatically.",
	aliases = { "i" },
})
args:add("watch", "flag", {
	help = "Watch for changes.",
	aliases = { "w" },
})
args:add("help", "flag", {
	help = "Show help.",
	aliases = { "h" },
})

args:parse(process.args)

if args:has("help") then
	args:help()
	process.exit(0)
end

if not args:has("watch") then
	if args:has("install") then
		build_plugin.install()
	else
		build_plugin.build()
	end
else
	print("now watching")

	const function step()
		if args:has("install") then
			build_plugin.install()
		else
			build_plugin.build()
		end
		print(rt.dim("Awaiting file change.."))
	end

	step()
	lute_fs.watch("src", function()
		step()
	end)
end
