-- from https://github.com/alicesaidhi/videkit_ty/blob/main/src/components/button.luau

const vide = require "@pkgs/vide"

const color = require "../../util/studio_color"
const container = require "./container"
const padding = require "./padding"
const studio_types = require "../../util/studio_types"

local create = vide.create
local source = vide.source
local spring = vide.spring
local changed = vide.changed
local read = vide.read

type Can<T> = T | () -> T
export type ButtonProps = {
	primary: Can<boolean>?,
	disabled: Can<boolean>?,
	text: Can<string>,

	on_activated: ((InputObject, number) -> ())?,

	layout: vide.Properties<TextButton>?,
	layout_text: vide.Properties<TextLabel>?,
	child: vide.Properties<Frame>?,

	_custom: Can<any>?,
	_noborder: Can<boolean>?,
	_selected: Can<boolean>?,
	_nopadding: Can<boolean>?,
	_nocorner: Can<boolean>?,
}

-- TODO: better algorithm for disabbled colors

const function button(props: ButtonProps)
	const primary = props.primary
	const gui_state = source(Enum.GuiState.Idle)
	const disabled = props.disabled or false

	const no_padding = props._nopadding
	const no_border = props._noborder
	const no_corner = props._nocorner
	const selected = props._selected

	const function modifier(): studio_types.StudioModifiers
		return if gui_state() == Enum.GuiState.NonInteractable
			then "Disabled"
			elseif read(selected) then "Selected"
			elseif gui_state() == Enum.GuiState.Press then "Pressed"
			elseif gui_state() == Enum.GuiState.Hover then "Hover"
			else "Default"
	end

	const button_color = color(props._custom or function()
		return if read(primary) then "MainButton" else "Button"
	end, modifier)

	const border_color = color(
		(function()
			return if read(primary) then "MainButton" else "Border"
		end) :: any,
		"Pressed"
	)

	return create "TextButton" {

		Size = UDim2.new(1, 0, 0, 24),
		AutomaticSize = Enum.AutomaticSize.Y,

		Interactable = function()
			return not read(disabled)
		end,

		BackgroundColor3 = spring(function()
			const color = button_color()
			if not vide.read(disabled) then
				return color
			end

			const h, s, v = color:ToHSV()
			print(h, s, v)

			return Color3.fromHSV(
				h,
				s * if s < 0.5 then s else s * 0.25,
				v * if v < 0.5 then v + (1 - v) * 0.3 else v * 0.85
			)
		end, 1 / 12, 1),
		AutoButtonColor = false,

		Activated = props.on_activated,

		create "UICorner" {
			CornerRadius = function()
				return if read(no_corner) then UDim.new() else UDim.new(0, 4)
			end,
		},

		create "UIStroke" {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = function()
				const color = border_color()
				if not vide.read(disabled) then
					return color
				end

				const h, s, v = color:ToHSV()

				return Color3.fromHSV(
					h,
					s * if s < 0.5 then s else s * 0.25,
					v * if v < 0.5 then v + (1 - v) * 0.3 else v * 0.85
				)
			end,
			Enabled = function()
				return not read(no_border)
			end,
		},

		container {

			create "TextLabel" {
				AutomaticSize = Enum.AutomaticSize.XY,
				Position = UDim2.fromScale(0, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),

				BackgroundTransparency = 1,

				Text = props.text,
				TextColor3 = color((function()
					return if read(primary) then "BrightText" else "ButtonText"
				end) :: any),
				Font = Enum.Font.SourceSans,
				TextSize = 16,
				TextTruncate = Enum.TextTruncate.AtEnd,

				props.layout_text,
			},

			props.child,
		},

		function()
			if read(no_padding) then
				return {}
			end
			return padding {
				padding = UDim.new(0, 6),
			}
		end,

		changed("GuiState", gui_state :: any),

		props.layout,
	}
end

return button
