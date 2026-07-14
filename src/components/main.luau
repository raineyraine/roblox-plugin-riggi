--!strict

const ChangeHistoryService = game:GetService "ChangeHistoryService"
const HttpService = game:GetService "HttpService"
const MaterialService = game:GetService "MaterialService"
const StudioService = game:GetService "StudioService"
const Workspace = game:GetService "Workspace"

const vide = require "@pkgs/vide"
const source = vide.source
const effect = vide.effect

const perdere_loader = require "@plugin/libs/perdere_loader"
const rig_cleaner = require "@plugin/libs/rig_cleaner"

const background = require "./core/background"
const button = require "./core/button"
const padding = require "./core/padding"
local foreground = require "./core/foreground"
const scroll_frame = require "./core/scroll_frame"
const text = require "./core/text"
const dropdown = require "./core/dropdown"
const row = require "./core/row"
const loading_circle = require "./core/loading_circle"

const outfit_list = require "./outfit_list"
local alert_list = require("./alert_list")

const store = require "@plugin/store"
const state = store.state
local alerts = require "@plugin/store/alerts"

const assets = require "@assets"

const FOLDER_NAME = "riggi_plugin_loaded"

const function import(
	material: (Enum.Material | string)?,
	useFolder: boolean,
	noFix: boolean,
	file: string?,
	fileName: string?
)
	if material == "Original" then
		material = nil
	end
	local folder = Workspace:FindFirstChild(FOLDER_NAME)
	local offset = 0

	if useFolder then
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = FOLDER_NAME
			folder.Parent = Workspace
		end

		offset = #(folder :: Folder):GetChildren()
	end

	local origin = if Workspace.CurrentCamera and not useFolder then Workspace.CurrentCamera.CFrame else CFrame.new()

	local files: { File | string } = if file
		then { file }
		else StudioService:PromptImportFilesAsync({ "txt", "json" }) :: any

	for i, file: File | string in files do
		if i % 3 == 0 then
			task.wait()
		end
		local decoded = if typeof(file) == "string"
			then HttpService:JSONDecode(file)
			else HttpService:JSONDecode(file:GetBinaryContents())

		local clone = assets.r6_rig:Clone()
		clone:PivotTo(origin * CFrame.new(-5 * (i - 1 + offset), 0, 0))
		const materialName = if typeof(material) == "EnumItem"
			then material.Name
			elseif typeof(material) == "string" then material
			else "Original"

		clone.Name = string.gsub(fileName or (file :: any).Name, "%.[^%.]+$", "") .. `({materialName})`

		clone.Parent = if useFolder then folder else Workspace

		perdere_loader.load_to_rig(clone, decoded)
		if not noFix then
			rig_cleaner.clean_rig(clone, material)
		end
	end
	ChangeHistoryService:SetWaypoint("loaded rigs")
end

const materials: { string } = { "Original", "EntirelyBlankPlastic" }
for _, material in Enum.Material:GetEnumItems() do
	if material == Enum.Material.Air or material == Enum.Material.Water then
		continue
	end
	table.insert(materials, material.Name)
end

return function(plugin: Plugin)
	const selectedMaterialIndex = source(1)
	const loadingAssets = source(false)

	const useFolder = source(false)

	const alertScrollRef = source(nil :: ScrollingFrame?)

	effect(function()
		const alertScroll = (alertScrollRef :: any)() :: ScrollingFrame?
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
							return if loadingAssets()
								then "Loading characters.."
								elseif #state.selected_outfits() == 0 then "Import files"
								else "Import selected"
						end,
						primary = function()
							return not loadingAssets()
						end,
						layout = {
							LayoutOrder = 0,
						},
						disabled = loadingAssets,
						activated = function()
							loadingAssets(true)
							const selected = state.selected_outfits()
							if #selected == 0 then
								import(
									materials[vide.untrack(selectedMaterialIndex)],
									true,
									vide.untrack(useFolder),
									nil,
									nil
								)
							else
								for _, name in selected do
									const outfit = state.outfits()[name]
									import(
										materials[vide.untrack(selectedMaterialIndex)],
										true,
										vide.untrack(useFolder),
										outfit,
										name
									)
								end
							end

							loadingAssets(false)
							print("DONE")
						end,
					},
					vide.show(loadingAssets, function()
						return loading_circle {}
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
						selected = selectedMaterialIndex,
						update_selected = selectedMaterialIndex,

						options = materials,
					},

					button {
						text = "Setup material variant",
						layout = {
							LayoutOrder = 2,
							Size = UDim2.new(0, 0, 0, 24),
							AutomaticSize = Enum.AutomaticSize.X,
						},
						activated = function()
							const variant =
								MaterialService:GetMaterialVariant(Enum.Material.Plastic, "EntirelyBlankPlastic")
							if variant then
								variant:Destroy()
							end

							const newVariant = Instance.new("MaterialVariant")
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
