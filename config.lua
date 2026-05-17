local tattooData <const> = require("shared.tattoos")
local sharedData <const> = require("shared.data")

local config = {}

config.debug = true

---@type "target" | "point"
config.interactionType = "point"

config.accentColor = "blue"

config.defaultFov = 50

config.rcoreTattoosCompatibility = false

config.invincibleDuringCustomization = true

config.freezeDuringCustomization = true

config.hideRadar = false

config.defaultShapeMix = 0.5
config.defaultSkinMix = 0.5

config.eyeColorMax = 31

config.headBlendRanges = {
	parent = { min = 0, max = 45, step = 1 },
	skin = { min = 0, max = 45, step = 1 },
	mix = { min = 0, max = 1, step = 0.01 },
}

config.modelLoadTimeout = 5000
config.animationLoadTimeout = 5000

config.animationBlendIn = 8.0
config.animationBlendOut = -8.0

config.cameraTransitionTime = 500

config.lightingTimes = {
	studio = { 18, 0, 0 },
	day    = { 12, 0, 0 },
	night  = { 0, 0, 0 },
}

config.limits = {
	maxPresets = 50,
	maxOutfits = 50,
	maxPayloadSize = 100000,
}

config.defaultBlip = {
	sprite = 1,
	color = 0,
	scale = 0.7,
}

config.defaultLocationRadius = 2.0
config.defaultClothingRoomRadius = 1.5

config.targetIcons = {
	location = "fas fa-tshirt",
	clothingRoom = "fas fa-door-open",
}

config.disabledComponents = {} -- e.g. { 9 } to disable body armor
config.disabledProps = {}

config.pedModels = {
	{ value = "mp_m_freemode_01", label = "Freemode Male" },
	{ value = "mp_f_freemode_01", label = "Freemode Female" },
}

config.cameraOffsets = {
	face = {
		offset = vector3(0.0, 0.7, 0.65),
		rotation = vector3(-5.0, 0.0, 0.0)
	},
	three_quarter = {
		offset = vector3(0.5, 1.2, 0.3),
		rotation = vector3(-5.0, 0.0, 0.0)
	},
	full_body = {
		offset = vector3(0.0, 2.5, 0.2),
		rotation = vector3(-5.0, 0.0, 0.0)
	},
}

config.cameraPresets = {
	{ value = "face", label = "Face" },
	{ value = "three_quarter", label = "3/4" },
	{ value = "full_body", label = "Full Body" },
}

config.lightingPresets = {
	{ value = "studio", label = "Studio" },
	{ value = "day", label = "Day" },
	{ value = "night", label = "Night" },
}

config.cameraDefaults = {
	preset = "full_body",
	lighting = "studio",
	fov = 50,
	zoom = 1,
	rotation = 0,
}

config.cameraRanges = {
	fov = { min = 20, max = 90, step = 1 },
	zoom = { min = 0.5, max = 3, step = 0.1 },
	rotation = { min = -180, max = 180, step = 1 },
}

config.outfitCategories = {
	{ value = "casual", label = "Casual" },
	{ value = "work", label = "Work" },
	{ value = "formal", label = "Formal" },
	{ value = "custom", label = "Custom" },
}

config.locations = {
	{
		type = "clothing_store",
		label = "Clothing Store",
		coords = vector3(1693.2, 4828.11, 42.07),
		radius = 2.0,
		tabs = { "clothing", "props", "outfits"},
		blip = {
			sprite = 73,
			color = 47,
			scale = 0.7,
			label = "Clothing Store"
		},
	},
	{
		type = "clothing_store",
		label = "Clothing Store",
		coords = vector3(-705.5, -149.22, 37.42),
		radius = 2.0,
		tabs = { "clothing", "props", "outfits" },
		blip = {
			sprite = 73,
			color = 47,
			scale = 0.7,
			label = "Clothing Store"
		},
	},
	{
		type = "clothing_store",
		label = "Clothing Store",
		coords = vector3(-1192.61, -768.4, 17.32),
		radius = 2.0,
		tabs = { "clothing", "props", "outfits" },
		blip = {
			sprite = 73,
			color = 47,
			scale = 0.7,
			label = "Clothing Store"
		},
	},
	{
		type = "clothing_store",
		label = "Clothing Store",
		coords = vector3(425.91, -801.03, 29.49),
		radius = 2.0,
		tabs = { "clothing", "props", "outfits" },
		blip = {
			sprite = 73,
			color = 47,
			scale = 0.7,
			label = "Clothing Store"
		},
	},
	{
		type = "clothing_store",
		label = "Clothing Store",
		coords = vector3(-168.73, -301.41, 39.73),
		radius = 2.0,
		tabs = { "clothing", "props", "outfits" },
		blip = {
			sprite = 73,
			color = 47,
			scale = 0.7,
			label = "Clothing Store"
		},
	},
	{
		type = "clothing_store",
		label = "Clothing Store",
		coords = vector3(75.39, -1398.28, 29.38),
		radius = 2.0,
		tabs = { "clothing", "props", "outfits" },
		blip = {
			sprite = 73,
			color = 47,
			scale = 0.7,
			label = "Clothing Store"
		},
	},
	{
		type = "clothing_store",
		label = "Clothing Store",
		coords = vector3(-827.39, -1075.93, 11.33),
		radius = 2.0,
		tabs = { "clothing", "props", "outfits" },
		blip = {
			sprite = 73,
			color = 47,
			scale = 0.7,
			label = "Clothing Store"
		},
	},
	{
		type = "clothing_store",
		label = "Clothing Store",
		coords = vector3(-1445.86, -240.78, 49.82),
		radius = 2.0,
		tabs = { "clothing", "props", "outfits" },
		blip = {
			sprite = 73,
			color = 47,
			scale = 0.7,
			label = "Clothing Store"
		},
	},
	{
		type = "clothing_store",
		label = "Clothing Store",
		coords = vector3(9.22, 6515.74, 31.88),
		radius = 2.0,
		tabs = { "clothing", "props", "outfits" },
		blip = {
			sprite = 73,
			color = 47,
			scale = 0.7,
			label = "Clothing Store"
		},
	},
	{
		type = "clothing_store",
		label = "Clothing Store",
		coords = vector3(615.35, 2762.72, 42.09),
		radius = 2.0,
		tabs = { "clothing", "props", "outfits" },
		blip = {
			sprite = 73,
			color = 47,
			scale = 0.7,
			label = "Clothing Store"
		},
	},
	{
		type = "clothing_store",
		label = "Clothing Store",
		coords = vector3(1191.61, 2710.91, 38.22),
		radius = 2.0,
		tabs = { "clothing", "props", "outfits" },
		blip = {
			sprite = 73,
			color = 47,
			scale = 0.7,
			label = "Clothing Store"
		},
	},
	{
		type = "clothing_store",
		label = "Clothing Store",
		coords = vector3(-3171.32, 1043.56, 20.86),
		radius = 2.0,
		tabs = { "clothing", "props", "outfits" },
		blip = {
			sprite = 73,
			color = 47,
			scale = 0.7,
			label = "Clothing Store"
		},
	},
	{
		type = "clothing_store",
		label = "Clothing Store",
		coords = vector3(-1105.52, 2707.79, 19.11),
		radius = 2.0,
		tabs = { "clothing", "props", "outfits" },
		blip = {
			sprite = 73,
			color = 47,
			scale = 0.7,
			label = "Clothing Store"
		},
	},
	{
		type = "clothing_store",
		label = "Clothing Store",
		coords = vector3(-1119.24, -1440.6, 5.23),
		radius = 2.0,
		tabs = { "clothing", "props", "outfits" },
		blip = {
			sprite = 73,
			color = 47,
			scale = 0.7,
			label = "Clothing Store"
		},
	},
	{
		type = "clothing_store",
		label = "Clothing Store",
		coords = vector3(124.82, -224.36, 54.56),
		radius = 2.0,
		tabs = { "clothing", "props", "outfits" },
		blip = {
			sprite = 73,
			color = 47,
			scale = 0.7,
			label = "Clothing Store"
		},
	},
	{
		type = "barber",
		label = "Barber Shop",
		coords = vector3(-814.22, -183.7, 37.57),
		radius = 1.5,
		tabs = { "hair", "face", "colors" },
		blip = {
			sprite = 71,
			color = 0,
			scale = 0.7,
			label = "Barber Shop"
		},
	},
	{
		type = "barber",
		label = "Barber Shop",
		coords = vector3(136.78, -1708.4, 29.29),
		radius = 1.5,
		tabs = { "hair", "face", "colors" },
		blip = {
			sprite = 71,
			color = 0,
			scale = 0.7,
			label = "Barber Shop"
		},
	},
	{
		type = "barber",
		label = "Barber Shop",
		coords = vector3(-1282.57, -1116.84, 6.99),
		radius = 1.5,
		tabs = { "hair", "face", "colors" },
		blip = {
			sprite = 71,
			color = 0,
			scale = 0.7,
			label = "Barber Shop"
		},
	},
	{
		type = "barber",
		label = "Barber Shop",
		coords = vector3(1931.41, 3729.73, 32.84),
		radius = 1.5,
		tabs = { "hair", "face", "colors" },
		blip = {
			sprite = 71,
			color = 0,
			scale = 0.7,
			label = "Barber Shop"
		},
	},
	{
		type = "barber",
		label = "Barber Shop",
		coords = vector3(1212.8, -472.9, 65.2),
		radius = 1.5,
		tabs = { "hair", "face", "colors" },
		blip = {
			sprite = 71,
			color = 0,
			scale = 0.7,
			label = "Barber Shop"
		},
	},
	{
		type = "barber",
		label = "Barber Shop",
		coords = vector3(-32.9, -152.3, 56.1),
		radius = 1.5,
		tabs = { "hair", "face", "colors" },
		blip = {
			sprite = 71,
			color = 0,
			scale = 0.7,
			label = "Barber Shop"
		},
	},
	{
		type = "barber",
		label = "Barber Shop",
		coords = vector3(-278.1, 6228.5, 30.7),
		radius = 1.5,
		tabs = { "hair", "face", "colors" },
		blip = {
			sprite = 71,
			color = 0,
			scale = 0.7,
			label = "Barber Shop"
		},
	},
	{
		type = "tattoo",
		label = "Tattoo Parlor",
		coords = vector3(1322.6, -1651.9, 51.2),
		radius = 1.5,
		tabs = { "tattoos" },
		blip = {
			sprite = 75,
			color = 1,
			scale = 0.7,
			label = "Tattoo Parlor"
		},
	},
	{
		type = "tattoo",
		label = "Tattoo Parlor",
		coords = vector3(-1154.01, -1425.31, 4.95),
		radius = 1.5,
		tabs = { "tattoos" },
		blip = {
			sprite = 75,
			color = 1,
			scale = 0.7,
			label = "Tattoo Parlor"
		},
	},
	{
		type = "tattoo",
		label = "Tattoo Parlor",
		coords = vector3(322.62, 180.34, 103.59),
		radius = 1.5,
		tabs = { "tattoos" },
		blip = {
			sprite = 75,
			color = 1,
			scale = 0.7,
			label = "Tattoo Parlor"
		},
	},
	{
		type = "tattoo",
		label = "Tattoo Parlor",
		coords = vector3(-3169.52, 1074.86, 20.83),
		radius = 1.5,
		tabs = { "tattoos" },
		blip = {
			sprite = 75,
			color = 1,
			scale = 0.7,
			label = "Tattoo Parlor"
		},
	},
	{
		type = "tattoo",
		label = "Tattoo Parlor",
		coords = vector3(1864.1, 3747.91, 33.03),
		radius = 1.5,
		tabs = { "tattoos" },
		blip = {
			sprite = 75,
			color = 1,
			scale = 0.7,
			label = "Tattoo Parlor"
		},
	},
	{
		type = "tattoo",
		label = "Tattoo Parlor",
		coords = vector3(-294.24, 6200.12, 31.49),
		radius = 1.5,
		tabs = { "tattoos" },
		blip = {
			sprite = 75,
			color = 1,
			scale = 0.7,
			label = "Tattoo Parlor"
		},
	},
	{
		type = "surgeon",
		label = "Plastic Surgeon",
		coords = vector3(298.78, -572.81, 43.26),
		radius = 1.5,
		tabs = { "face", "colors" },
		blip = {
			sprite = 102,
			color = 2,
			scale = 0.7,
			label = "Plastic Surgeon"
		},
	},
}

config.prices = {
	clothing_store = 100,
	barber = 100,
	tattoo = 100,
	surgeon = 500,
}

config.chargePerTattoo = false

config.blacklist = {
	enabled = false,

	---@type "blacklist" | "whitelist"
	mode = "blacklist",

	clothing = {
	},

	props = {
	},
}

config.clothingRooms = {
}

config.pedMenu = {
	enabled = true,
	command = "pedmenu",
	acePermission = false,
	models = false,
}

config.commands = {
	reloadSkin = "reloadskin",
}

config.admin = {
	enabled = true,
	command = "setappearance",
	acePermission = "admin.appearance",
}

config.factionUniforms = {
  enabled = true,
  command = "uniforms",
  saveCurrentAsCommand = "saveuniform",
  maxPerFaction = 25,
  defaultBossGrade = 4,
  bossGrades = {
  },
  acePermission = "appearance.uniforms",
  includeAccessories = true,
}

config.share = {
	enabled = true,
	codeLength = 10,
	maxPayloadBytes = 100000, -- 100 KiB cap on serialized outfit payload
	rateLimitGen = 5,
	rateLimitImport = 20,
	rateLimitWindowMs = 60000,
	defaultMaxUses = 0,
	defaultTtlSeconds = 0,
}

config.wardrobe = {
	enabled = true,
	maxSlots = 4,
}

config.tattoos = tattooData.list
config.tattooZones = tattooData.zones

config.componentIds = sharedData.componentIds
config.propIds = sharedData.propIds
config.componentLabels = sharedData.componentLabels
config.clothingComponentGroups = sharedData.clothingComponentGroups
config.accessoryComponentIds = sharedData.accessoryComponentIds
config.propLabels = sharedData.propLabels
config.overlayLabels = sharedData.overlayLabels
config.overlayGroups = sharedData.overlayGroups
config.faceFeatures = sharedData.faceFeatures
config.faceFeatureLabels = sharedData.faceFeatureLabels
config.faceRegions = sharedData.faceRegions
config.animations = sharedData.animations
config.quickSlots = sharedData.quickSlots
config.walkStyles = sharedData.walkStyles
config.walkStyleCategories = sharedData.walkStyleCategories

return config