local vide = require "@pkgs/vide"
local create = vide.create

local color = require "../../util/studio_color"

export type BackgroundProps = vide.Properties<Frame>

return function(props: BackgroundProps)
	return create "Frame" {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = color "MainBackground",
		BorderSizePixel = 0,

		props,
	}
end
