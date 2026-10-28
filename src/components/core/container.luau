-- from https://github.com/alicesaidhi/videkit_ty/blob/main/src/components/container.luau

const vide = require "@pkgs/vide"
local create = vide.create

local function container(props: vide.Properties<Frame>)
	return create "Frame" {

		Name = "Container",

		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		props,
	}
end

return container
