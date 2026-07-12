--!strict

local process = require "@lune/process"

local pathfs = require "@lune_pkgs/pathfs"

local cli = require "@batteries/cli"
local rt = require "@batteries/richterm"

local build_plugin = require "./lib/build_plugin"

local args = cli.parser()
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
	pathfs.watchDirectories({ "src" }, function()
		if args:has("install") then
			build_plugin.install()
		else
			build_plugin.build()
		end
		print(rt.dim("Awaiting file change.."))
	end)
end
