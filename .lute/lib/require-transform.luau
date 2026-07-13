-- TODO: do this
const path = require "@std/path"
const json = require "@std/json"
const fs = require "@std/fs"

const patterns = {
	`require%s*"(.-)"`,
	`require%s*'(.-)'`,
	`require%s*%(%s*"(.-)"%s*%)`,
	`require%s*%(%s*'(.-)'%s*%)`,
}

const function transform_source(fromPath: path.Pathlike, luaurcPath: path.Pathlike, sourcemapPath: path.Pathlike)
	const source = fs.readFileToString(fromPath)
	const luaurc: json.Object = json.deserialize(fs.readFileToString(luaurcPath)) :: any
	assert(json.asObject(luaurc), "luaurc is not a json object")
	const sourcemap: json.Object = json.deserialize(fs.readFileToString(sourcemapPath)) :: any
	assert(json.asObject(sourcemap), "sourcemap is not a json object")

	const aliases: json.Object = luaurc["aliases"] :: any
	assert(json.asObject(aliases), "luaurc.aliases is not a json object")

	local transformed = source

	for _, pattern in patterns do
		transformed = string.gsub(transformed, pattern, function(match)
			const first = string.sub(match, 1, 1)
			if first ~= "@" then
				return `require("{match}")`
			end

			const alias = string.match(match, "^@([^/]+)")
			assert(alias, "missing alias?!")
			assert(aliases[alias], `alias '{alias}' not present in luaurc`)
			const after = string.match(match, "^@[^/]+(.*)")

			return `require("{aliases[alias]}{after}")`
		end)
	end

	return transformed
end

print(transform_source("src/app.luau", ".luaurc", "sourcemap.json"))
