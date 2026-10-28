-- from https://github.com/alicesaidhi/videkit_ty/blob/main/src/components/list.luau

const vide = require "@pkgs/vide"
local create = vide.create

const container = require "./container"

type can<T> = T | () -> T
type layout = {
	list: vide.Properties<UIListLayout>?,
	layout: vide.Properties<Frame>?,

	[number]: any,
}

local function layout(props: layout)
	return container {

		create "UIListLayout" {
			Padding = UDim.new(0, 8),

			props.list,
		},

		props.layout,

		unpack(props),
	}
end

return layout
