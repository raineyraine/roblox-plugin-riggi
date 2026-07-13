--!strict

const vide = require "@pkgs/vide"
const root = vide.root

const store = require "./store"
const state = store.state
store.state.plugin(plugin) -- important!

const app = require "./app"
const keys = require "./keys"

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
