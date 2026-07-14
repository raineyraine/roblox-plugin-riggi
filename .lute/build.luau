--!strict

const lute_fs = require "@lute/fs"
const process = require "@std/process"
const fs = require "@std/fs"
const path = require "@std/path"
const task = require "@std/task"

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

local running_step: thread? = nil

const function step(watched: boolean?)
	if running_step then
		task.cancel(running_step)
	end

	running_step = task.spawn(function()
		if args:has("install") then
			build_plugin.install()
		else
			build_plugin.build()
		end

		if watched then
			print(rt.dim "Awaiting file change..")
		end
	end)
end

print("initial build")

step(args:has("watch"))

if args:has("watch") then
	print("now watching")
	print(rt.dim "Awaiting file change..")

	const walker = fs.walk("src", { recursive = true })
	const paths: { path.Path } = {}

	local walked = walker()

	while walked do
		const walkedPath = path.join(table.unpack(walked.parts))
		const type = fs.type(walkedPath)

		if type == "dir" then
			table.insert(paths, walkedPath)
		end

		walked = walker()
	end

	for _, watch in paths do
		lute_fs.watch(path.format(watch), function(event)
			step(true)
		end)
	end
end
