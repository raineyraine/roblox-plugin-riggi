--from https://github.com/alicesaidhi/videkit_ty/blob/main/src/components/foreground.luau

local color = require "@plugin/util/studio_color"
local vide = require "@pkgs/vide"

local create = vide.create

type background = vide.Properties<Frame>

local function background(props: background)
	return create "Frame" {
		Name = "Foreground",

		Size = UDim2.fromScale(1, 1),

		BackgroundColor3 = color("Tab", "Default"),

		props,
	}
end

return background
