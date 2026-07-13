--!strict

const ChangeHistoryService = game:GetService "ChangeHistoryService"
const HttpService = game:GetService "HttpService"
const StudioService = game:GetService "StudioService"
const Workspace = game:GetService "Workspace"

const vide = require "@pkgs/vide"
const source = vide.source

const perdere_loader = require "@plugin/libs/perdere_loader"
const rig_cleaner = require "@plugin/libs/rig_cleaner"

const background = require "./core/background"
const button = require "./core/button"
const padding = require "./core/padding"
const row = require "./core/row"

const outfit_list = require "./outfit_list"

const store = require "@plugin/store"
local state = store.state
const actions = store.actions

const assets = require "@assets"
local foreground = require "./core/foreground"

const FOLDER_NAME = "riggi_plugin_loaded"

const function import(material: Enum.Material?, useFolder: boolean, noFix: boolean?, file: string?, fileName: string?)
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
		local decoded = if typeof(file) == "string"
			then HttpService:JSONDecode(file)
			else HttpService:JSONDecode(file:GetBinaryContents())

		local clone = assets.r6_rig:Clone()
		clone:PivotTo(origin * CFrame.new(-5 * (i - 1 + offset), 0, 0))
		clone.Name = string.gsub(fileName or (file :: any).Name, "%.[^%.]+$", "")
			.. `{if material then ` ({material.Name})` else ""}`
		clone.Parent = if useFolder then folder else Workspace

		perdere_loader.load_to_rig(clone, decoded)
		if not noFix then
			rig_cleaner.clean_rig(clone, material)
		end
	end
	ChangeHistoryService:SetWaypoint("loaded rigs")
end

return function(plugin: Plugin)
	return background {
		padding {},
		vide.create "UIListLayout" {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 8),
		},

		outfit_list(),

		foreground {
			Size = UDim2.new(1, 0, 0, 2),
			LayoutOrder = 1,
		},

		button {
			text = function(): string
				return if #state.selected_outfits() == 0 then "Import files" else "Import selected"
			end,
			primary = true,
			layout = {
				LayoutOrder = 2,
			},
			activated = function()
				const selected = state.selected_outfits()
				if #selected == 0 then
					import(Enum.Material.SmoothPlastic, true)
				else
					for _, name in selected do
						const outfit = state.outfits()[name]
						import(Enum.Material.SmoothPlastic, true, nil, outfit, name)
					end
				end
			end,
		},
	}
end
