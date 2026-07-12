--!strict

local types = require "./types"

export type JSONColor3 = types.JSONColor3
export type JSONVector3 = types.JSONVector3
export type AccessoryData = types.AccessoryData
export type PresetData = types.PresetData

-- utils from upstream
local function json_col3_to_col3(jc3: JSONColor3?)
	if not jc3 then
		return Color3.new(1, 1, 1)
	end

	return Color3.new(jc3.R or 1, jc3.G or 1, jc3.B or 1)
end

local function json_vec3_to_vec3(jv3: JSONVector3)
	return Vector3.new(jv3.X, jv3.Y, jv3.Z) :: Vector3
end

local function load_body_colors(JSONBodyColors: { [string]: JSONColor3 }, body_colors: BodyColors)
	body_colors.HeadColor3 = json_col3_to_col3(JSONBodyColors["HeadColor3"])
	body_colors.LeftArmColor3 = json_col3_to_col3(JSONBodyColors["LeftArmColor3"])
	body_colors.LeftLegColor3 = json_col3_to_col3(JSONBodyColors["LeftLegColor3"])
	body_colors.RightArmColor3 = json_col3_to_col3(JSONBodyColors["RightArmColor3"])
	body_colors.RightLegColor3 = json_col3_to_col3(JSONBodyColors["RightLegColor3"])
	body_colors.TorsoColor3 = json_col3_to_col3(JSONBodyColors["TorsoColor3"])
end

local lib = {}

function lib.load_to_rig(character: Model, data: PresetData)
	-- type: will always be a Shirt, but luau cannot detect this
	local shirt = character:FindFirstChildWhichIsA("Shirt") :: Shirt
	if not shirt then
		shirt = Instance.new("Shirt")
		shirt.Parent = character
	end
	-- type: will always be a Pants, but luau cannot detect this
	local pants = character:FindFirstChildWhichIsA("Pants") :: Pants
	if not pants then
		pants = Instance.new("Pants")
		pants.Parent = character
	end

	local head = character:FindFirstChild("Head")
	assert(head and head:IsA("BasePart"), `no head found for {character}`)
	local face = head:FindFirstChild("face") :: Decal
	assert(face and face:IsA("Decal"), `no face found for {character}`)

	if string.len(data.Shirt) >= 0 then
		shirt.ShirtTemplate = data.Shirt
	end
	if string.len(data.Pants) >= 0 then
		pants.PantsTemplate = data.Pants
	end
	if string.len(data.Face) >= 0 then
		face.Texture = data.Face
	end

	for _, child in pairs(character:GetChildren()) do
		if child:IsA("Accessory") then
			child:Destroy()
		end
	end

	for _, accessory: AccessoryData in pairs(data.Accessories) do
		local new_accessory = Instance.new("Accessory")
		new_accessory.Name = accessory.Name

		local handle = Instance.new("Part")
		handle.Name = "Handle"
		handle.Size = json_vec3_to_vec3(accessory.HandleSize)
		handle.Transparency = accessory.HandleTransparency
		handle.Color = json_col3_to_col3(accessory.HandleColor or { R = 1, G = 1, B = 1 })
		handle.Reflectance = accessory.HandleReflectance or 0
		-- upstream_change type errors
		-- handle.Material = Enum.Material[accessory.HandleMaterial or "Plastic"]
		handle.Material = Enum.Material:FromName(accessory.HandleMaterial or "Plastic") or Enum.Material.Plastic
		handle.Anchored = false
		handle.CanCollide = false
		handle.Parent = new_accessory

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.Name = "SpecialMesh"
		mesh.Parent = handle
		mesh.MeshId = accessory.MeshId
		mesh.TextureId = accessory.TextureId
		mesh.Offset = json_vec3_to_vec3(accessory.Offset)
		mesh.Scale = json_vec3_to_vec3(accessory.Scale)
		mesh.VertexColor = json_vec3_to_vec3(accessory.VertexColor)

		local attachment = Instance.new("Attachment")
		attachment.Name = accessory.AttachmentName
		attachment.Position = json_vec3_to_vec3(accessory.AttachmentPosition)
		attachment.Orientation = json_vec3_to_vec3(accessory.AttachmentOrientation)
		attachment.Parent = handle

		if accessory.HandleLight then
			local lightData = accessory.HandleLight

			local lightType = lightData.Type or "PointLight"
			if lightType ~= "PointLight" and lightType ~= "SpotLight" and lightType ~= "SurfaceLight" then
				lightType = "PointLight"
			end

			-- upstream_change silence type errors
			-- local newLight = Instance.new(lightType)
			local newLight = Instance.new(lightType) :: any
			newLight.Brightness = lightData.Brightness or 1
			newLight.Color = json_col3_to_col3(lightData.Color or { R = 1, G = 1, B = 1 })
			newLight.Enabled = lightData.Enabled ~= false

			if lightData.Range then
				newLight.Range = lightData.Range
			end

			if lightData.Angle and (newLight:IsA("SpotLight") or newLight:IsA("SurfaceLight")) then
				newLight.Angle = lightData.Angle
			end
			if lightData.Face and (newLight:IsA("SpotLight") or newLight:IsA("SurfaceLight")) then
				pcall(function()
					-- upstream_change type errors
					-- newLight.Face = Enum.NormalId[lightData.Face]
					newLight.Face = Enum.NormalId:FromName(lightData.Face) or Enum.NormalId.Front
				end)
			end

			newLight.Parent = handle
		end

		new_accessory.Parent = character

		task.defer(function()
			-- upstream_change types
			-- local weld = handle:FindFirstChild("AccessoryWeld")
			local weld = handle:WaitForChild("AccessoryWeld", 5) :: Weld
			-- upstream_change end
			if weld and accessory.WeldC1Position and accessory.WeldC1Rotation then
				local pos = json_vec3_to_vec3(accessory.WeldC1Position)

				local x, y, z = string.match(accessory.WeldC1Rotation, "([^,]+),([^,]+),([^,]+)")
				x, y, z = tonumber(x), tonumber(y), tonumber(z :: string)

				if x and y and z then
					weld.C1 = CFrame.new(pos) * CFrame.Angles(math.rad(x), math.rad(y), math.rad(z))
				end
			end
		end)
	end

	local body_colors = character:FindFirstChildWhichIsA("BodyColors")
	if data["BodyColors"] and body_colors then
		load_body_colors(data["BodyColors"], body_colors)
	end
end

return lib
