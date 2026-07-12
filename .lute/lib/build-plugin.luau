--!strict

const fs = require "@std/fs"
const process = require "@std/process"
const path = require "@std/path"

const rt = require "@batteries/richterm"

const studio_install = require "./studio-install"

const DIST = "dist"

const build_plugin = {}

const function exec_and_await(args: { string }, options: process.ProcessRunOptions?): process.ProcessResult
	print(rt.blue(rt.dim "$ " .. table.concat(args, " ")))
	return process.run(args, options)
end

function build(): path.Pathlike?
	if fs.exists(DIST) and fs.type(DIST) == "dir" then
		fs.removeDirectory(DIST, { recursive = true })
	end
	fs.createDirectory(DIST)

	print(rt.dim "installing dependencies")
	local result = exec_and_await({ "pesde", "install" }, {
		stdio = "inherit",
	})
	if result.ok then
		print(rt.green "installed dependencies!\n")
	else
		print(rt.red "failed to install dependencies!\n")
		return nil
	end

	print(rt.dim "generating sourcemap")
	result = exec_and_await({ "rojo", "sourcemap", "sourcemap.project.json", "-o", "sourcemap.json" }, {
		stdio = "inherit",
	})
	if result.ok then
		print(rt.green "sourcemap generated!\n")
	else
		print(rt.red "failed to generate sourcemap!\n")
		return nil
	end

	print(rt.dim "running darklua..")
	result = exec_and_await({ "darklua", "process", "src", "dist" }, {
		stdio = "inherit",
	})
	if result.ok then
		print(rt.green "darklua ran!\n")
	else
		print(rt.red "darklua failed!\n")
		return nil
	end

	print(rt.dim "building..")
	result = exec_and_await({ "rojo", "build", "build.project.json", "-o", "plugin.rbxm" }, {
		stdio = "inherit",
	})
	if result.ok then
		print(rt.green "built!\n")
	else
		print(rt.red "failed to build!\n")
		return nil
	end

	return "plugin.rbxm"
end
build_plugin.build = build

function install()
	local builtPath = build()
	assert(builtPath, "no built plugin?")
	local pluginPath = studio_install.get_plugin_path()
	assert(pluginPath, "no plugin path?")

	fs.copy(builtPath, path.join(pluginPath, "/riggi_plugin_dev.rbxm"), true)
end
build_plugin.install = install

return build_plugin
