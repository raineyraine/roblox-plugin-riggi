--!strict

local vide = require "@pkgs/vide"
local root = vide.root

local store = require "./store"
local state = store.state
store.state.plugin(plugin) -- important!

local app = require "./app"
local keys = require "./keys"

vide.defaults = true

do
	local saved_outfits = plugin:GetSetting(keys.saved_state.presets)
	print(saved_outfits)

	if saved_outfits and typeof(saved_outfits) == "table" then
		state.outfits(saved_outfits)
	end
end

local destroy = root(function()
	app(plugin)
end)

plugin.Deactivation:Connect(function()
	plugin:SetSetting(keys.saved_state.presets, state.outfits())
	destroy()
end)
