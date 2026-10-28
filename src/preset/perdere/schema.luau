const gt = require "@pkgs/greentea"

const jsonColor3Schema = gt.table {
	R = gt.number(),
	G = gt.number(),
	B = gt.number(),
}

const jsonVector3Schema = gt.table {
	X = gt.number(),
	Y = gt.number(),
	Z = gt.number(),
}

const accessoryDataSchema = gt.table {
	Name = gt.string(),

	MeshId = gt.string(),
	TextureId = gt.string(),
	Scale = jsonVector3Schema,
	VertexColor = jsonVector3Schema,
	Offset = jsonVector3Schema,

	HandleSize = jsonVector3Schema,
	HandleTransparency = gt.number(),
	HandleReflectance = gt.optional(gt.number()),
	HandleColor = jsonColor3Schema,
	HandleMaterial = gt.optional(gt.string()),

	HandleLight = gt.optional(gt.table {
		Brightness = gt.number(),
		Range = gt.number(),
		Color = jsonColor3Schema,
		Enabled = gt.boolean(),
		Type = gt.string(),
		Face = gt.optional(gt.string()),
		Angle = gt.optional(gt.number()),
	}),

	AttachmentName = gt.string(),
	AttachmentPosition = jsonVector3Schema,
	AttachmentOrientation = jsonVector3Schema,
	AccessoryBodyPart = gt.string(),

	WeldC1Position = gt.optional(jsonVector3Schema),
	WeldC1Rotation = gt.optional(gt.string()),
}

const presetDataSchema = gt.table {
	Accessories = gt.array(accessoryDataSchema),
	Shirt = gt.string(),
	Pants = gt.string(),
	Face = gt.string(),
	BodyColors = gt.dictionary(gt.string(), jsonColor3Schema),
	Name = gt.string(),
	Bio = gt.string(),
}

return {
	presetDataSchema = gt.build(presetDataSchema),
	accessoryDataSchema = gt.build(accessoryDataSchema),
	jsonVector3Schema = gt.build(jsonVector3Schema),
	jsonColor3Schema = gt.build(jsonColor3Schema),
}
