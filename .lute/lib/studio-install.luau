const system = require "@std/system"
const process = require "@std/process"
const path = require "@std/path"

const studio_install = {}

function studio_install.get_plugin_path(): path.Pathlike?
	if system.win32 then
		const localAppData = process.env["LOCALAPPDATA"]
		if not localAppData then
			return nil
		end
		return path.join(localAppData, "\\Roblox\\Plugins")
	elseif system.macos then
		const home = process.env["HOME"]
		if not home then
			return nil
		end
		return path.join(home, "/Library/Roblox/Plugins")
	else
		return nil
	end
end

return studio_install
