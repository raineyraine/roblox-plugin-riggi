local RunService = game:GetService("RunService")

local color = require "@plugin/util/studio_color"
local vide = require "@pkgs/vide"
const read = vide.read
local create = vide.create
local source = vide.source
local cleanup = vide.cleanup

type can<T> = T | () -> T
type progress_circle = {
	size: can<number>?,
	width: can<number>?,
	layout: vide.Properties<Frame>?,
}

local DARK = Color3.fromRGB(11, 90, 175)
local HIGHLIGHT = Color3.fromRGB(0, 162, 255)
local color_sequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, DARK),
	ColorSequenceKeypoint.new(0.001, HIGHLIGHT),
	ColorSequenceKeypoint.new(0.4, HIGHLIGHT),
	ColorSequenceKeypoint.new(0.6, DARK),
	ColorSequenceKeypoint.new(1, DARK),
})

local function loading_circle(props: progress_circle)
	local rotation = source(0)

	cleanup(RunService.Heartbeat:Connect(function(dt)
		rotation(rotation() + dt * 360)
	end))

	return create "Frame" {

		Size = function()
			const size = (read(props.size) or 24) :: number
			return UDim2.fromOffset(size, size)
		end,

		BackgroundTransparency = 1,

		create "Frame" {

			Size = function()
				const size = (read(props.size) or 24) :: number
				return UDim2.fromOffset(size, size)
			end,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),

			BackgroundColor3 = Color3.new(1, 1, 1),

			create "UICorner" {
				CornerRadius = UDim.new(1, 0),
			},

			create "UIGradient" {
				Color = color_sequence,
				Rotation = rotation,
			},
		},

		create "Frame" {

			Size = function()
				const size = (read(props.size) or 24) :: number
				const width = (read(props.width) or 8) :: number
				return UDim2.fromOffset(size - width, size - width)
			end,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),

			BackgroundColor3 = color("MainBackground"),

			create "UICorner" {
				CornerRadius = UDim.new(1, 0),
			},
		},

		props.layout,
	}
end

return loading_circle
