--!nocheck
-- TODO: make strict

local AssetService = game:GetService("AssetService")

local lib = {}

local function clean_rig(rig: Model, material_to_use: Enum.Material?)
	for _, v in rig:GetChildren() do
		if v:IsA("Accessory") then
			local handle = v:FindFirstChild("Handle") :: BasePart
			local mesh = handle:FindFirstChildOfClass("SpecialMesh")
			local weld = handle:FindFirstChildOfClass("Weld")
			local Size = mesh.Scale
			local Offset = mesh.Offset
			local oldCFrame = handle.CFrame

			local mp = AssetService:CreateMeshPartAsync(Content.fromUri(mesh.MeshId))
			mp.Material = if material_to_use then material_to_use else handle.Material
			mp.Color = handle.Color
			mp.Reflectance = handle.Reflectance
			mp.Transparency = handle.Transparency
			mp.TextureID = mesh.TextureId
			mp.Name = v.Name
			mp.Anchored = true
			mp.Parent = weld.Part1
			mp.Size = mp.Size * Size
			local attachment = handle:FindFirstChildOfClass("Attachment")
			if not attachment then
				v:Destroy()
				continue
			end
			attachment.Parent = mp

			local part_1 = weld.Part1
			local other_attachment = part_1:FindFirstChild(attachment.Name) :: Attachment
			-- mp.CFrame = (
			-- 	(other_attachment :: any).Parent.CFrame
			-- 	* other_attachment.CFrame
			-- 	* attachment.CFrame:Inverse()
			-- ) + Offset
			mp.CFrame = handle.CFrame

			v.Parent = nil
		end
	end

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
