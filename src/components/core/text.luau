--!strict
-- from https://github.com/alicesaidhi/videkit_ty/blob/main/src/components/text.luau

local color = require "@plugin/util/studio_color"
local vide = require "@pkgs/vide"

local create = vide.create

type can<T> = T | () -> T
type text = vide.Properties<TextLabel>

local function text(props: text)
	return create "TextLabel" {

		Size = UDim2.new(),
		AutomaticSize = Enum.AutomaticSize.XY,

		BackgroundTransparency = 1,

		TextColor3 = color("MainText"),
		Font = Enum.Font.SourceSans,
		TextSize = 16,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,

		props,
	}
end

return text
