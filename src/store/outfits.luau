const vide = require "@pkgs/vide"
const source = vide.source

const keys = require "../keys"

const core = require "./core"
const core_state = core.state

type Map<Key, Value> = { [Key]: Value }

const state = {
	outfits = source({} :: Map<string, string>),
}

const actions = {}

function actions.set_outfit(key: string, value: string): ()
	local new_outfits = table.clone(state.outfits())

	new_outfits[key] = value

	state.outfits(new_outfits)
	core_state.plugin():SetSetting(keys.saved_state.presets, new_outfits)
end

function actions.remove_outfit(key: string): ()
	local new_outfits = table.clone(state.outfits())

	new_outfits[key] = nil

	state.outfits(new_outfits)
	core_state.plugin():SetSetting(keys.saved_state.presets, new_outfits)
end

return {
	state = state,
	actions = actions,
}
