-- modified https://github.com/alicesaidhi/videkit_ty/blob/main/src/components/scroll_frame.luau

local vide = require "@pkgs/vide"
local create = vide.create

local color = require "../../util/studio_color"

type Can<T> = T | () -> T
type ScrollFrameProps = vide.Properties<ScrollingFrame>

local function scroll_frame(props: ScrollFrameProps)
	return create "ScrollingFrame" {

		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.XY,

		BackgroundTransparency = 1,

		ScrollBarThickness = 6,
		ScrollBarImageColor3 = color "SubText",

		props,
	}
end

return scroll_frame
