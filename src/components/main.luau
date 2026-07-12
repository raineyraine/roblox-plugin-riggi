--!strict

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Workspace = game:GetService("Workspace")

local vide = require "@pkgs/vide"

local perdere_loader = require "@plugin/libs/perdere_loader"
local rig_cleaner = require "@plugin/libs/rig_cleaner"

local background = require "./core/background"
local button = require "./core/button"
local padding = require "./core/padding"

local store = require "@plugin/store"
local state = store.state
local actions = store.actions

local assets = require "@assets"

local FOLDER_NAME = "riggi_plugin_loaded"

local function import(material: Enum.Material?, useFolder: boolean, noFix: boolean?)
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

	local files = StudioService:PromptImportFilesAsync({ "txt", "json" })
	for i, file in files do
		if not file:IsA("File") then
			continue
		end
		local decoded = HttpService:JSONDecode(file:GetBinaryContents())

		local clone = assets.r6_rig:Clone()
		clone:PivotTo(origin * CFrame.new(-5 * (i - 1 + offset), 0, 0))
		clone.Name = string.gsub(file.Name, "%.[^%.]+$", "") .. `{if material then ` ({material.Name})` else ""}`
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
		button {
			primary = true,
			activated = function()
				import(nil, true)
			end,
			text = "Import rigs",
			layout = { LayoutOrder = 0 },
		},
		button {
			primary = false,
			activated = function()
				import(nil, false)
			end,
			text = "Import rigs here",
			layout = { LayoutOrder = 1 },
		},
		button {
			primary = false,
			activated = function()
				import(Enum.Material.Plastic, true)
			end,
			text = "Import rigs (Plastic)",
			layout = { LayoutOrder = 2 },
		},
		button {
			primary = false,
			activated = function()
				import(Enum.Material.SmoothPlastic, true)
			end,
			text = "Import rigs (SmoothPlastic)",
			layout = { LayoutOrder = 3 },
		},
		button {
			primary = false,
			activated = function()
				import(nil, true, true)
			end,
			text = "dev_import_no_fix",
			layout = { LayoutOrder = 3.1 },
		},
		button {
			primary = false,
			activated = function()
				local folder = Workspace:FindFirstChild(FOLDER_NAME) :: Folder
				if not folder then
					folder = Instance.new("Folder")
					folder.Name = FOLDER_NAME
					folder.Parent = Workspace
				end

				ChangeHistoryService:SetWaypoint("pre-clear rigs")
				folder:ClearAllChildren()
				ChangeHistoryService:SetWaypoint("cleared rigs")
			end,
			text = "Clear rig folder",
			layout = { LayoutOrder = 4 },
		},
		button {
			primary = true,
			activated = function()
				local files = StudioService:PromptImportFilesAsync({ "txt", "json" })
				for i, file in files do
					if not file:IsA("File") then
						continue
					end
					actions.set_outfit(string.gsub(file.Name, "%.[^%.]+$", ""), file:GetBinaryContents())
				end
			end,
			text = "dev open_gui",
			layout = { LayoutOrder = 5 },
		},
	}
end
