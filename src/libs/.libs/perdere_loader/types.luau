--!strict

export type JSONColor3 = {
	R: number,
	G: number,
	B: number,
}

export type JSONVector3 = {
	X: number,
	Y: number,
	Z: number,
}

export type AccessoryData = {
	-- accessory
	Name: string,

	-- mesh
	MeshId: string,
	TextureId: string,
	Scale: JSONVector3,
	VertexColor: JSONVector3,
	Offset: JSONVector3,

	-- handle
	HandleSize: JSONVector3,
	HandleTransparency: number,
	HandleReflectance: number?,
	HandleColor: JSONColor3?,
	HandleMaterial: string?,

	HandleLight: {
		Brightness: number,
		Range: number,
		Color: JSONColor3,
		Enabled: boolean,
		Type: string,
		Face: string,
		Angle: number,
	}?,

	-- attachment
	AttachmentName: string,
	AttachmentPosition: JSONVector3,
	AttachmentOrientation: JSONVector3,
	AccessoryBodyPart: string,

	-- weld
	WeldC1Position: JSONVector3?,
	WeldC1Rotation: string?,
}

export type PresetData = {
	["Accessories"]: { AccessoryData },
	["Shirt"]: string,
	["Pants"]: string,
	["Face"]: string,
	["BodyColors"]: { [string]: JSONColor3 },
	["Name"]: string,
	["Bio"]: string,
}

return nil
