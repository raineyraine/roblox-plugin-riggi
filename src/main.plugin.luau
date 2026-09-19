const RunService = game:GetService "RunService"
if RunService:IsClient() or RunService:IsServer() then
	plugin:Deactivate()
end

const vide = require "@pkgs/vide"
const root = vide.root

const core = require "./store/core"
core.state.plugin(plugin) -- important!

const outfits = require "./store/outfits"

const app = require "./app"
const keys = require "./keys"

vide.defaults = true

do
	local saved_outfits = plugin:GetSetting(keys.saved_state.presets)

	if saved_outfits and typeof(saved_outfits) == "table" then
		outfits.state.outfits(saved_outfits)
	end
end

local destroy = root(function()
	app(plugin)
end)

plugin.Unloading:Connect(function()
	plugin:SetSetting(keys.saved_state.presets, outfits.state.outfits())
	destroy()
end)
