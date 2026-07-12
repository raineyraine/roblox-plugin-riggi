--!strict

local vide = require "@pkgs/vide"
local source = vide.source
local read = vide.read

local studio_types = require "./studio_types"
local types = require "../types"

local studio = settings():GetService("Studio")

type Can<T> = types.Can<T>

export type StudioColorHook =
	((color: Can<studio_types.StudioColors>, modifier: Can<studio_types.StudioModifiers>?) -> () -> Color3)
	& (() -> string)

export type StudioColors = studio_types.StudioColors
export type StudioModifiers = studio_types.StudioModifiers

local theme = source() :: vide.Source<StudioTheme>
local function update_theme()
	theme(studio.Theme :: StudioTheme)
end
local connection: RBXScriptConnection?

local function studio_color(
	color: Can<studio_types.StudioColors>,
	modifier: Can<studio_types.StudioModifiers>?
): unknown
	if not color then
		return theme().Name
	end

	if not connection then
		update_theme()
		connection = studio.ThemeChanged:Connect(update_theme)
	end

	return function()
		return theme():GetColor(
			Enum.StudioStyleGuideColor:FromName(read(color) :: any) or Enum.StudioStyleGuideColor.MainBackground,
			Enum.StudioStyleGuideModifier:FromName(read(modifier) :: any or "Default")
		)
	end
end

return studio_color :: StudioColorHook
