--!strict
-- from https://github.com/alicesaidhi/videkit_ty/blob/main/src/components/row.luau

const vide = require "@pkgs/vide"
const create = vide.create

const container = require "./container"

type can<T> = T | () -> T
type layout = {
	list: vide.Properties<UIListLayout>?,
	layout: vide.Properties<Frame>?,

	[number]: any,
}

local function layout(props: layout)
	return container {

		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

		create "UIListLayout" {
			Padding = UDim.new(0, 8),
			FillDirection = Enum.FillDirection.Horizontal,

			props.list,
		},

		props.layout,

		unpack(props),
	}
end

return layout
