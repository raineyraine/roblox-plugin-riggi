local StudioService = game:GetService "StudioService"

const vide = require "@pkgs/vide"
const source = vide.source
const changed = vide.changed
const spring = vide.spring
const effect = vide.effect

const alerts = require "@plugin/store/alerts"
const core = require "@plugin/store/core"
const outfits = require "@plugin/store/outfits"

const studio_color = require "@plugin/util/studio_color"
const studio_types = require "@plugin/util/studio_types"
local widget_prompt = require "../util/widget_prompt"

const button = require "./core/button"
const list = require "./core/list"
const padding = require "./core/padding"
local prompt_string_outfit = require "./prompt_string_outfit"
const radio_button = require "./core/radio_button"
const row = require "./core/row"
const scroll_frame = require "./core/scroll_frame"
const text = require "./core/text"
const text_input = require "./core/text_input"

const function prompt_import_string_outfit(): widget_prompt.PromptResult<prompt_string_outfit.OutfitImportResult>
	const info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, true, true, 500, 500, 500, 500)

	return widget_prompt
		.spawn_prompt_widget("prompt_import_str_outfit", info, prompt_string_outfit, "Import outfit from string")
		.on_cancel(function()
			alerts.actions.alert("warn", "String import cancelled")
		end)
end

return function()
	const frameHeight = source(-8)
	const absoluteCanvasSize = source(Vector2.new(0, 0))
	const absoluteSize = source(Vector2.new(0, 0))

	const searchText = source ""
	return list {
		layout = {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 0,
		},

		row {
			list = {
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			},
			text {
				Text = "Outfit list",
				LayoutOrder = 0,
			},
			text_input {

				text = searchText,
				update_text = function(new)
					searchText(new)
				end,
				placeholder = "Search",
				layout = {
					LayoutOrder = 1,
					Size = UDim2.new(1, 0, 0, 24),
					vide.create "UISizeConstraint" {
						MaxSize = Vector2.new(200, math.huge),
					},
				},
			},
		},

		scroll_frame {
			Size = function()
				return UDim2.new(1, 0, 0, math.clamp(frameHeight(), 40, 300))
			end,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,

			vide.create "UIListLayout" {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 8),
			},

			vide.create "UIPadding" {
				PaddingRight = function()
					return UDim.new(0, if absoluteCanvasSize().Y > absoluteSize().Y then 6 + 8 else 0)
				end,
			},

			changed("AbsoluteCanvasSize", absoluteCanvasSize :: any),
			changed("AbsoluteSize", absoluteSize :: any),

			vide.indexes(outfits.state.outfits, function(value: () -> string, key)
				const selected = source(false)
				const matchesSearch = source(true)
				const foundIndex = source(-1)
				const foundEnd = source(0)

				local guiState = source(Enum.GuiState.Idle)
				frameHeight(frameHeight() + 40 + 8)

				effect(function(): ()
					const query = searchText()
					if query == "" then
						matchesSearch(true)
					else
						const start, ending = string.find(key, query)
						foundIndex(start or -1)
						foundEnd(ending or -1)

						matchesSearch(not not start)
					end
				end)

				return vide.create "TextButton" {
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					AutoButtonColor = false,

					padding {},

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

					vide.create "UIStroke" {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						BorderStrokePosition = Enum.BorderStrokePosition.Inner,
						Color = studio_color(function(): studio_types.StudioColors
							return if selected() then "MainButton" else "Tab"
						end, "Default"),
					},

					vide.create "UICorner" {
						CornerRadius = UDim.new(0, 4),
					},

					MouseButton1Click = function()
						selected(not selected())
						const old = table.clone(core.state.selected_outfits())

						if not selected() then
							table.remove(old, table.find(old, key))
						else
							table.insert(old, key)
						end

						core.state.selected_outfits(old)
					end,

					changed("GuiState", guiState :: any),

					Visible = function()
						return selected() or matchesSearch()
					end,

					list {
						list = {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalFlex = Enum.UIFlexAlignment.Fill,
							VerticalAlignment = Enum.VerticalAlignment.Center,
						},
						layout = {
							AutomaticSize = Enum.AutomaticSize.Y,
						},
						radio_button {
							toggled = selected,
							update_toggled = function(new)
								selected(new)
								const old = table.clone(core.state.selected_outfits())

								if not new then
									table.remove(old, table.find(old, key))
								else
									table.insert(old, key)
								end

								core.state.selected_outfits(old)
							end,

							vide.create "UIFlexItem" {
								GrowRatio = 0,
								ShrinkRatio = 0,
							},
						},

						text {
							Text = function()
								if foundIndex() > 0 and searchText() ~= "" then
									const first = string.sub(key, 0, foundIndex() - 1)
									const inner = string.sub(key, foundIndex(), foundEnd())
									const last = string.sub(key, foundEnd() + 1, -1)

									return `{first}<b>{inner}</b>{last}`
								end

								return key
							end,
							LayoutOrder = 1,
							Size = UDim2.new(1, 0, 0, 24),
							RichText = true,
							TextTruncate = Enum.TextTruncate.AtEnd,
						},

						text {
							Text = "perdere",
							TextSize = 14,
							LayoutOrder = 2,
							BackgroundTransparency = 0,
							BackgroundColor3 = studio_color "InputFieldBackground",

							padding {
								y = UDim.new(0, 4),
								x = UDim.new(0, 8),
							},
							vide.create "UIFlexItem" {
								GrowRatio = 0,
							},
							vide.create "UIStroke" {
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = studio_color "InputFieldBorder",
							},
							vide.create "UICorner" {
								CornerRadius = UDim.new(1, 0),
							},
						},

						button {
							text = "Delete",
							layout = {
								LayoutOrder = 3,
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
								TextTruncate = Enum.TextTruncate.None,
							},
							on_activated = function()
								const old = table.clone(core.state.selected_outfits())
								if selected() then
									table.remove(old, table.find(old, key))
								end
								core.state.selected_outfits(old)

								frameHeight(frameHeight() - 40 - 8)
								outfits.actions.remove_outfit(key)
							end,
						},
					},
				}
			end),

			vide.create "TextButton" {
				Size = UDim2.new(1, 0, 0, 40),
				AutomaticSize = Enum.AutomaticSize.Y,
				AutoButtonColor = false,

				padding {},

				BackgroundColor3 = studio_color("Tab", "Default"),

				vide.create "UICorner" {
					CornerRadius = UDim.new(0, 4),
				},

				Visible = function()
					return not next(outfits.state.outfits())
				end,

				text {
					LayoutOrder = -1,
					Text = "No outfits — add some!",
					AutomaticSize = Enum.AutomaticSize.XY,
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
				},
			},
		},

		row {
			layout = { LayoutOrder = 2 },
			list = { HorizontalFlex = Enum.UIFlexAlignment.Fill },
			button {
				layout = { LayoutOrder = 0 },
				text = "Add outfit",
				on_activated = function()
					const files = StudioService:PromptImportFilesAsync { "json", "txt" }
					for _, file: File in files do
						const stripped = string.match(file.Name, "(.-)%..*")
						if not stripped then
							continue
						end

						const existing = outfits.state.outfits()[stripped]
						if existing ~= nil then
							alerts.actions.alert(
								"warn",
								`Unable to add outfit <b>{stripped}</b> since it already exists. Delete it first!`
							)
							continue
						end
						outfits.actions.set_outfit(stripped, file:GetBinaryContents())
					end
				end,
			},
			button {
				layout = { LayoutOrder = 1 },
				text = "Add outfit (from string)",
				on_activated = function()
					const res = prompt_import_string_outfit()

					res.and_then(function(value: prompt_string_outfit.OutfitImportResult)
						const existing = outfits.state.outfits()[value.name]
						if existing ~= nil then
							alerts.actions.alert(
								"warn",
								`Unable to add outfit <b>{value.name}</b> since it already exists. Delete it first!`
							)
						end
						outfits.actions.set_outfit(value.name, value.outfit)
					end)
				end,
			},
		},
	}
end
