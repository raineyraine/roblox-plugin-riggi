const vide = require "@pkgs/vide"

const background = require "@plugin/components/core/background"
const text_input = require "@plugin/components/core/text_input"

const button = require "./core/button"
const padding = require "./core/padding"
const row = require "./core/row"
const widget_prompt = require "@plugin/util/widget_prompt"

return function(_: Plugin, props: widget_prompt.PromptAppProps<string>)
	const text = vide.source ""

	return background {
		Size = UDim2.fromScale(1, 1),
		padding {},
		vide.create "UIListLayout" {
			FillDirection = Enum.FillDirection.Vertical,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			VerticalFlex = Enum.UIFlexAlignment.Fill,
			Padding = UDim.new(0, 8),
		},
		text_input {
			layout = {
				LayoutOrder = 0,
				Size = UDim2.fromScale(1, 1),
				vide.changed("Text", text :: any),
				TextYAlignment = Enum.TextYAlignment.Top,
			},
			placeholder = "Paste an import string",
			focus_lost = function(new: string, enter_pressed: boolean)
				if enter_pressed then
					props.submit(new)
				end
			end,
		},
		row {
			layout = { LayoutOrder = 1 },
			list = { HorizontalFlex = Enum.UIFlexAlignment.None, HorizontalAlignment = Enum.HorizontalAlignment.Right },
			button {
				layout = {
					AutomaticSize = Enum.AutomaticSize.XY,
					Size = UDim2.new(0, 0, 0, 24),
				},
				text = "Submit",

				primary = true,

				on_activated = function()
					props.submit(vide.read(text) :: string)
				end,
			},
			button {
				text = "Cancel",
				primary = false,
				layout = {
					AutomaticSize = Enum.AutomaticSize.XY,
					Size = UDim2.new(0, 0, 0, 24),
				},

				on_activated = function()
					props.cancel()
				end,
			},
		},
	}
end
