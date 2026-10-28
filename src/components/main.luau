const ChangeHistoryService = game:GetService "ChangeHistoryService"
const HttpService = game:GetService "HttpService"
const MaterialService = game:GetService "MaterialService"
const StudioService = game:GetService "StudioService"
const Workspace = game:GetService "Workspace"

const vide = require "@pkgs/vide"
const source = vide.source
const effect = vide.effect

const perdere_loader = require "@plugin/preset/perdere/loader"
const rig_cleaner = require "@plugin/libs/rig_cleaner"

const background = require "./core/background"
const button = require "./core/button"
const dropdown = require "./core/dropdown"
const foreground = require "./core/foreground"
const loading_circle = require "./core/loading_circle"
const padding = require "./core/padding"
const row = require "./core/row"
const scroll_frame = require "./core/scroll_frame"
const text = require "./core/text"

const alert_list = require "./alert_list"
const outfit_list = require "./outfit_list"
const prompt_string = require "./prompt_string"

const alerts = require "@plugin/store/alerts"
const core = require "@plugin/store/core"
const outfits = require "@plugin/store/outfits"
const widget_prompt = require "@plugin/util/widget_prompt"

const assets = require "@assets"

const FOLDER_NAME = "riggi_plugin_loaded"

const function import(
	material: (Enum.Material | string)?,
	use_folder: boolean,
	no_fix: boolean,
	file: string?,
	file_name: string?
)
	if material == "Original" then
		material = nil
	end
	local folder = Workspace:FindFirstChild(FOLDER_NAME)
	local offset = 0

	if use_folder then
		if not folder then
			folder = Instance.new "Folder"
			folder.Name = FOLDER_NAME
			folder.Parent = Workspace
		end

		offset = #(folder :: Folder):GetChildren()
	end

	const origin = if Workspace.CurrentCamera and not use_folder then Workspace.CurrentCamera.CFrame else CFrame.new()

	const files: { File | string } = if file
		then { file }
		else StudioService:PromptImportFilesAsync { "txt", "json" } :: any

	for i, file: File | string in files do
		if i % 3 == 0 then
			task.wait()
		end
		local decoded = ""
		const binary_contents = if typeof(file) == "string" then file else file:GetBinaryContents()

		do
			const success, result = pcall(HttpService.JSONDecode, HttpService, binary_contents)
			if not success then
				alerts.actions.alert(
					"error",
					`Failed to load outfit <b>{file_name or (file :: any).Name}</b><br/>A full log is available in the Output window`
				)

				warn(`Failure loading outfit {file_name or (file :: any).Name}:\n{result}`)
				continue
			end

			decoded = result
		end

		const clone = assets.r6_rig:Clone()
		clone:PivotTo(origin * CFrame.new(-5 * (i - 1 + offset), 0, 0))
		const materialName = if typeof(material) == "EnumItem"
			then material.Name
			elseif typeof(material) == "string" then material
			else "Original"

		clone.Name = string.gsub(
			file_name or if typeof(file) == "string" then file elseif file == nil then "Unknown" else file.Name,
			"%.[^%.]+$",
			""
		) .. `({materialName})`

		clone.Parent = if use_folder then folder else Workspace

		const success, message = pcall(function()
			perdere_loader.load_to_rig(clone, decoded)
			if not no_fix then
				rig_cleaner.clean_rig(clone, material)
			end
		end)

		if not success then
			alerts.actions.alert(
				"error",
				`Failed to load outfit <b>{file_name or (file :: any).Name}</b><br/>A full log is available in the Output window`
			)

			warn(`Failure loading outfit {file_name or (file :: any).Name}:\n{message}`)
		end
	end
	ChangeHistoryService:SetWaypoint "loaded rigs"
end

const function prompt_import_string(): widget_prompt.PromptResult<string>
	const info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, true, true, 500, 500, 500, 500)

	return widget_prompt
		.spawn_prompt_widget("prompt_import_str", info, prompt_string, "Import string")
		.on_cancel(function()
			alerts.actions.alert("warn", "String import cancelled")
		end)
end

const materials: { string } = { "Original", "EntirelyBlankPlastic" }
for _, material in Enum.Material:GetEnumItems() do
	if material == Enum.Material.Air or material == Enum.Material.Water then
		continue
	end
	table.insert(materials, material.Name)
end

return function(plugin: Plugin)
	const selected_material_index = source(1)
	const loading_assets = source(false)

	const use_folder = source(false)

	const alert_scroll_ref = source(nil :: ScrollingFrame?)

	effect(function()
		const alertScroll = (alert_scroll_ref :: any)() :: ScrollingFrame?
		if not alertScroll then
			return
		end

		alerts.state.alerts()

		alertScroll.CanvasPosition = Vector2.yAxis
			* (alertScroll.AbsoluteCanvasSize.Y - alertScroll.AbsoluteWindowSize.Y)
	end)

	return background {
		alert_list(),
		scroll_frame {
			background {
				Size = UDim2.fromScale(1, 1),
				padding {},
				vide.create "UIListLayout" {
					FillDirection = Enum.FillDirection.Vertical,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, 8),
				},
				vide.create "UISizeConstraint" {
					MinSize = Vector2.new(200, 300),
				},

				outfit_list(),

				foreground {
					Size = UDim2.new(1, 0, 0, 2),
					LayoutOrder = 1,
				},

				row {
					layout = { LayoutOrder = 2 },
					list = {
						VerticalAlignment = Enum.VerticalAlignment.Center,
						HorizontalFlex = Enum.UIFlexAlignment.Fill,
					},
					button {
						text = function(): string
							return if loading_assets()
								then "Loading characters.."
								elseif #core.state.selected_outfits() == 0 then "Import files"
								else "Import selected"
						end,
						primary = true,
						layout = {
							LayoutOrder = 1,
						},
						disabled = loading_assets,
						on_activated = function()
							loading_assets(true)
							const selected = core.state.selected_outfits()
							if #selected == 0 then
								import(
									materials[vide.untrack(selected_material_index)],
									true,
									vide.untrack(use_folder),
									nil,
									nil
								)
							else
								for _, name in selected do
									const outfit = outfits.state.outfits()[name]
									import(
										materials[vide.untrack(selected_material_index)],
										true,
										vide.untrack(use_folder),
										outfit,
										name
									)
								end
							end

							loading_assets(false)
						end,
					},
					button {
						text = "Import string",
						layout = {
							LayoutOrder = 1,
						},
						disabled = loading_assets,
						on_activated = function()
							const res = prompt_import_string()

							res.and_then(function(value: string)
								loading_assets(true)
								import(
									materials[vide.untrack(selected_material_index)],
									true,
									vide.untrack(use_folder),
									value
								)
								loading_assets(false)
							end)
						end,
					},
					vide.show(loading_assets, function()
						return loading_circle {
							layout = { LayoutOrder = 2 },
						}
					end),
				},

				row {
					layout = { LayoutOrder = 3 },
					list = {
						VerticalAlignment = Enum.VerticalAlignment.Center,
						HorizontalFlex = Enum.UIFlexAlignment.Fill,
					},

					text {
						Text = "Material",
						vide.create "UIFlexItem" {
							GrowRatio = 0,
						},
					},

					dropdown {
						selected = selected_material_index,
						update_selected = selected_material_index,

						options = materials,
					},

					button {
						text = "Setup material variant",
						layout = {
							LayoutOrder = 2,
							Size = UDim2.new(0, 0, 0, 24),
							AutomaticSize = Enum.AutomaticSize.X,
						},
						on_activated = function()
							const variant =
								MaterialService:GetMaterialVariant(Enum.Material.Plastic, "EntirelyBlankPlastic")
							if variant then
								variant:Destroy()
							end

							const newVariant = Instance.new "MaterialVariant"
							newVariant.BaseMaterial = Enum.Material.Plastic
							newVariant.Name = "EntirelyBlankPlastic"
							newVariant.Parent = MaterialService
						end,

						child = {
							vide.create "UIFlexItem" {
								GrowRatio = 0,
							},
						},
					},
				},
			},
		},
	}
end
