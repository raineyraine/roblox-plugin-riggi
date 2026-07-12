--!strict

local vide = require "@pkgs/vide"

local function ref(value: (Instance) -> ())
	return vide.action(value)
end

return ref
