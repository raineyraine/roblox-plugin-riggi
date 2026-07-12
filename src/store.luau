--!strict

local vide = require "@pkgs/vide"
local source = vide.source

local keys = require "./keys"

type Map<Key, Value> = { [Key]: Value }

local state = {
	open = source(false),
	settings = {},
	outfits = source({} :: Map<string, string>),
	plugin = source((nil :: any) :: Plugin),
}

local actions = {}

function actions.set_outfit(key: string, value: string): ()
	local new_outfits = table.clone(state.outfits())

	new_outfits[key] = value

	state.outfits(new_outfits)
	state.plugin():SetSetting(keys.saved_state.presets, new_outfits)
end

function actions.remove_outfit(key: string): ()
	local new_outfits = table.clone(state.outfits())

	new_outfits[key] = nil

	state.outfits(new_outfits)
	state.plugin():SetSetting(keys.saved_state.presets, new_outfits)
end

return { state = state, actions = actions }
