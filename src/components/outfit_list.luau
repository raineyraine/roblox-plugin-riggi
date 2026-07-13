local StudioService = game:GetService "StudioService"

const vide = require "@pkgs/vide"
const source = vide.source

const store = require "@plugin/store"

const foreground = require "./core/foreground"
const list = require "./core/list"
const row = require "./core/row"
const text = require "./core/text"
const padding = require "./core/padding"
const button = require "./core/button"
const radio_button = require "./core/radio_button"

return function()
	return list {
		layout = {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 0,
		},

		row {
			text {
				Text = "Outfit list",
				LayoutOrder = 0,
			},
		},

		vide.indexes(store.state.outfits, function(value, key)
			const selected = source(false)

			return foreground {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				padding {},

				list {
					list = {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalFlex = Enum.UIFlexAlignment.Fill,
					},
					layout = {
						AutomaticSize = Enum.AutomaticSize.Y,
					},
					radio_button {
						toggled = selected,
						update_toggled = function(new)
							selected(new)
							const old = table.clone(store.state.selected_outfits())

							if not new then
								table.remove(old, table.find(old, key))
							else
								table.insert(old, key)
							end

							print(old)

							store.state.selected_outfits(old)
						end,

						vide.create "UIFlexItem" {
							GrowRatio = 0,
							ShrinkRatio = 0,
						},
					},

					text {
						Text = key,
						LayoutOrder = 0,
						Size = UDim2.new(1, 0, 0, 24),
						TextTruncate = Enum.TextTruncate.AtEnd,
					},

					button {
						text = "Delete",
						layout = {
							LayoutOrder = 1,
							Size = UDim2.new(0, 64, 0, 24),
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.fromScale(1, 0),

							vide.create "UIFlexItem" {
								GrowRatio = 0,
								ShrinkRatio = 0,
							},
						},
						layout_text = {
							TextXAlignment = Enum.TextXAlignment.Center,
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
						},
						activated = function()
							store.actions.remove_outfit(key)
						end,
					},
				},
			}
		end),

		row {
			layout = { LayoutOrder = 2 },
			button {
				text = "Add outfit",
				activated = function()
					const files = StudioService:PromptImportFilesAsync({ "json", "txt" })
					for _, file: File in files do
						const stripped = string.match(file.Name, "(.-)%..*")
						if not stripped then
							continue
						end

						store.actions.set_outfit(stripped, file:GetBinaryContents())
					end
				end,
			},
		},
	}
end
