const process = require "@std/process"

const rt = require "@batteries/richterm"

const process_util = {}

function process_util.exec_and_await(args: { string }, options: process.ProcessRunOptions?): process.ProcessResult
	print(rt.blue(rt.dim "$ " .. table.concat(args, " ")))
	return process.run(args, options)
end

return process_util
