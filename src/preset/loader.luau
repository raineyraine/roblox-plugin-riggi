const perdere_loader = require "./perdere/loader"

const ty = require "./types"

const loader = {}

function loader.load_to_rig(character: Model, file: ty.OutfitFile)
	if file.dataKind == "perdere" then
		perdere_loader.load_to_rig(character, file.data)
	end

	error(`Unhandled outfit data type {file.dataKind}`)
end

return loader
