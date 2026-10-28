local vide = require "@pkgs/vide"

const background = require "@plugin/components/core/background"
const text_input = require "@plugin/components/core/text_input"

local button = require "./core/button"
local padding = require "./core/padding"
local row = require "./core/row"
const widget_prompt = require "@plugin/util/widget_prompt"

export type OutfitImportResult = { outfit: string, name: string }
return function(_: Plugin, props: widget_prompt.PromptAppProps<OutfitImportResult>)
	const outfit_data = vide.source ""
	const oufit_name = vide.source ""

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
				vide.changed("Text", outfit_data :: any),
				TextYAlignment = Enum.TextYAlignment.Top,
			},
			placeholder = "Paste an import string",
		},
		text_input {
			layout = {
				LayoutOrder = 0,
				Size = UDim2.new(1, 0, 0, 24),
				vide.changed("Text", oufit_name :: any),
			},
			placeholder = "Name",
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
				disabled = function()
					return outfit_data() == "" or oufit_name() == ""
				end,

				on_activated = function()
					if vide.read(outfit_data()) == "" or vide.read(oufit_name()) == "" then
						return
					end

					props.submit {
						outfit = vide.read(outfit_data :: any),
						name = vide.read(oufit_name :: any),
					}
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
