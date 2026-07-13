-- from https://github.com/alicesaidhi/videkit_ty/blob/main/src/components/radio_button.luau

const vide = require "@pkgs/vide"
const create = vide.create
const source = vide.source
const changed = vide.changed
const spring = vide.spring
const read = vide.read

local studio_types = require "@plugin/util/studio_types"
const color = require "@plugin/util/studio_color"

const background = require "./background"

type can<T> = T | () -> T
type radio_button = {
	toggled: can<boolean>,
	update_toggled: (new: boolean) -> (),

	[number]: any,
}

const function radio_button(props: radio_button)
	local toggled = props.toggled
	local update_toggled = props.update_toggled or function() end
	local gui_state = source(Enum.GuiState.Idle)

	local function modifier(): studio_types.StudioModifiers
		return if gui_state() == Enum.GuiState.Press
			then "Pressed"
			elseif gui_state() == Enum.GuiState.Hover then "Hover"
			else "Default"
	end

	return create "TextButton" {

		Size = UDim2.fromOffset(24, 24),
		AutomaticSize = Enum.AutomaticSize.XY,

		BackgroundTransparency = 1,

		changed("GuiState", gui_state :: any),

		Activated = function()
			update_toggled(not read(toggled))
		end,

		create "UIListLayout" {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8),
		},

		background {

			Size = UDim2.fromOffset(17, 17),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),

			BackgroundColor3 = spring(color("InputFieldBackground", modifier), 0.1),

			create "UICorner" {
				CornerRadius = UDim.new(1, 0),
			},

			create "UIStroke" {
				Color = color("InputFieldBorder", modifier),
			},

			create "ImageLabel" {

				Size = UDim2.fromOffset(9, 9),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),

				BackgroundTransparency = 1,

				ImageColor3 = color("MainButton"),
				ImageTransparency = spring(function()
					return if read(toggled) then 0 else 1
				end, 0.1),

				Image = "rbxasset://textures/AvatarEditorImages/circle_gray4.png",
				ScaleType = Enum.ScaleType.Crop,

				create "UICorner" {
					CornerRadius = UDim.new(1, 0),
				},
			},
		},

		unpack(props :: any),
	}
end

return radio_button
