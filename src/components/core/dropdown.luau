--!nocheck
-- TODO: support strict
-- from https://github.com/alicesaidhi/videkit_ty/blob/main/src/components/dropdown.luau

local vide = require "@pkgs/vide"
local create = vide.create
local source = vide.source
local changed = vide.changed
local indexes = vide.indexes
local spring = vide.spring
local read = vide.read

local button = require "./button"
local color = require "@plugin/util/studio_color"
local container = require "./container"
local list = require "./list"
local padding = require "./padding"
local portal = require "./portal"
local scroll_frame = require "./scroll_frame"

local MAX_SIZE = 100

type Can<T> = T | () -> T
type DropdownProps = {
	selected: Can<number>,
	update_selected: (() -> number)?,

	options: Can<{ string }>,
}

local function dropdown(props: DropdownProps)
	local selected = props.selected
	local update_selected = props.update_selected or function() end
	local options = props.options

	local enabled = source(false)
	local absolute_size = source(Vector2.zero)

	local size = spring(function()
		if not enabled() then
			return UDim2.fromScale(1, 0)
		end
		return UDim2.new(1, 0, 0, math.min(MAX_SIZE, absolute_size().Y))
	end, 0.1)

	return button {

		text = function()
			return read(options)[read(selected)]
		end,

		activated = function()
			enabled(not enabled())
		end,

		_custom = function()
			return if enabled() then "InputFieldBackground" else "EmulatorDropDown"
		end,

		child = {
			container {

				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.new(0, 18, 0, 16),
				create "ImageLabel" {

					Name = "arrow",

					Size = UDim2.new(0, 8, 0, 4),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Rotation = spring(function()
						return if enabled() then -180 else 0
					end, 0.1),

					BackgroundTransparency = 1,

					Image = "rbxassetid://7260137654",
					ImageColor3 = color("SubText"),
					ScaleType = Enum.ScaleType.Stretch,
				},
			},
		},

		layout = {
			Size = UDim2.fromOffset(200, 24),

			portal {
				inherit_layout = true,

				container {
					Position = UDim2.new(0, 0, 1, 4),
					Size = size,

					BackgroundTransparency = 0,
					BackgroundColor3 = color("EmulatorDropDown"),

					ClipsDescendants = true,

					Visible = function()
						return size().Y.Offset > 1
					end,

					padding {
						padding = UDim.new(0, 2),
					},

					scroll_frame {
						Size = UDim2.fromScale(1, 1),
						ScrollBarThickness = 4,

						changed("AbsoluteCanvasSize", absolute_size),

						list {
							layout = {
								Size = UDim2.new(1, -6, 1, 0),
								AutomaticSize = Enum.AutomaticSize.Y,
							},
							list = { Padding = UDim.new(0, 1) },

							indexes(function()
								return read(options)
							end, function(value, key)
								return button {
									text = value,
									_custom = "EmulatorDropDown",
									_noborder = true,

									activated = function()
										enabled(false)
										update_selected(key)
									end,
								}
							end),
						},
					},

					create "UIStroke" {
						Color = color("Border"),
					},

					create "UICorner" {
						CornerRadius = UDim.new(0, 3),
					},
				},
			},
		},
	}
end

return dropdown
