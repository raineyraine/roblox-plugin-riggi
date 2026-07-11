--!strict

local process = require "@lune/process"

local pathfs = require "@lune_pkgs/pathfs"

local build_plugin = require "./lib/build_plugin"

local do_install = table.find(process.args, "-i") or table.find(process.args, "--install")
local do_watch = table.find(process.args, "-w") or table.find(process.args, "--watch")

if not do_watch then
	if do_install then
		build_plugin.install()
	else
		build_plugin.build()
	end
else
	print("now watching")
	pathfs.watchDirectories({ "src" }, function()
		build_plugin.build()
		if do_install then
			build_plugin.install()
		end
	end)
end
