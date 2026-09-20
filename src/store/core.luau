const vide = require "@pkgs/vide"
const source = vide.source

type Map<Key, Value> = { [Key]: Value }
type Array<Value> = { Value }

local state = {
	open = source(false),
	settings = {},
	plugin = source((nil :: any) :: Plugin),
	selected_outfits = source({} :: Array<string>),
}

local actions = {}

return { state = state, actions = actions }
