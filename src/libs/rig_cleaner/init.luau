--!nocheck
-- TODO: make strict

local AssetService = game:GetService("AssetService")

local lib = {}

local function clean_rig(rig: Model, material: (Enum.Material | string)?)
	local loading = 0

	for _, v in rig:GetChildren() do
		if v:IsA("Accessory") then
			loading += 1
			print(loading)
			task.spawn(function()
				local handle = v:FindFirstChild("Handle") :: BasePart
				local mesh = handle:FindFirstChildOfClass("SpecialMesh")
				local weld = handle:FindFirstChildOfClass("Weld")
				local Size = mesh.Scale

				local success, mp: MeshPart = pcall(function()
					return AssetService:CreateMeshPartAsync(Content.fromUri(mesh.MeshId))
				end)
				if not success then
					warn(`Failed to make MeshPart for accessory {v.Name}`)
					loading -= 1
					return
				end
				loading -= 1

				if typeof(material) == "EnumItem" then
					mp.Material = material
				elseif typeof(material) == "string" then
					mp.Material = Enum.Material.Plastic
					mp.MaterialVariant = material
				else
					mp.Material = handle.Material
				end

				mp.Color = handle.Color
				mp.Reflectance = handle.Reflectance
				mp.Transparency = handle.Transparency
				mp.TextureID = mesh.TextureId
				-- TODO: proper support for this
				if mp.TextureID == "rbxassetid://0" or mp.TextureID == "rbxassetid://1" then
					mp.TextureID = ""
				end
				mp.Name = v.Name
				mp.Anchored = true
				mp.Parent = weld.Part1
				mp.Size = mp.Size * Size
				local attachment = handle:FindFirstChildOfClass("Attachment")
				if not attachment then
					v:Destroy()
					return
				end
				attachment.Parent = mp

				-- mp.CFrame = (
				-- 	(other_attachment :: any).Parent.CFrame
				-- 	* other_attachment.CFrame
				-- 	* attachment.CFrame:Inverse()
				-- ) + Offset
				mp.CFrame = handle.CFrame

				v:Destroy()
			end)
		end
	end

	repeat
		task.wait()
	until loading == 0

	for _, v in rig:GetChildren() do
		if v:IsA("BasePart") then
			for _, basepart_child in v:GetChildren() do
				if basepart_child:IsA("Attachment") or basepart_child:IsA("Motor6D") then
					basepart_child:Destroy()
				end
			end
		end
	end

	local head = rig:FindFirstChild("Head") :: BasePart
	head.PivotOffset = CFrame.new(Vector3.new(0, -(head.Size.Y / 2), 0))

	head.Name = "Noggin"
	head.Reflectance = 1
	head.Reflectance = 0
end
lib.clean_rig = clean_rig

return lib
