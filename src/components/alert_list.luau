const vide = require "@pkgs/vide"
const source = vide.source
const spring = vide.spring
const effect = vide.effect

const container = require "./core/container"
const padding = require "./core/padding"
const text = require "./core/text"

const alerts = require "@plugin/store/alerts"
const studio_color = require "@plugin/util/studio_color"
const studio_types = require "@plugin/util/studio_types"

return function()
	return container {
		padding {},
		ZIndex = 5,
		vide.create "UIListLayout" {
			Padding = UDim.new(0, 8),
			FillDirection = Enum.FillDirection.Vertical,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
		},

		vide.values(alerts.state.alerts, function(value: alerts.Alert, index, active: () -> boolean)
			const transparency = source(1)
			const transparencySpring = vide.spring(transparency, 1 / 4, 1)
			const guiState = source(Enum.GuiState.Idle)

			effect(function()
				if active() then
					transparency(0)
				else
					transparency(1)
				end
			end)

			return vide.create "TextButton" {
				Size = UDim2.fromScale(0, 0),
				BackgroundTransparency = transparencySpring,
				AutomaticSize = Enum.AutomaticSize.XY,

				BackgroundColor3 = spring(
					studio_color("Tab", function(): studio_types.StudioModifiers
						return if guiState() == Enum.GuiState.Press
							then "Pressed"
							elseif guiState() == Enum.GuiState.Hover then "Hover"
							else "Default"
					end),
					1 / 12,
					1
				),

				MouseButton1Click = function()
					alerts.actions.remove_alert(value.id)
				end,

				vide.changed("GuiState", guiState :: any),

				padding {},
				vide.create "UICorner" {
					CornerRadius = UDim.new(0, 8),
				},
				text {
					Text = value.message,
					RichText = true,
					TextTransparency = transparencySpring,
				},
			},
				1 / 4
		end),
	}
end
