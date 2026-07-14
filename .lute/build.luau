--!strict

const process = require "@std/process"
const task = require "@std/task"

const cli = require "@batteries/cli"

const build_plugin = require "./lib/build-plugin"

const args = cli.parser()
args:add("install", "flag", {
	help = "Install to the Studio plugin folder automatically.",
	aliases = { "i" },
})
args:add("help", "flag", {
	help = "Show help.",
	aliases = { "h" },
})
args:add("watch", "flag", {
	help = "Watch files",
	aliases = { "w" },
})

args:parse(process.args)

if args:has("help") then
	args:help()
	process.exit(0)
end

if args:has("watch") then
	process.run({ "watchexec", "-w", "src", "--", "lute", "build", "-i" }, { stdio = "inherit" })
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
	end)
end

step()
