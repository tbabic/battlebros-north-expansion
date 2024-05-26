if(::mods_getRegisteredMod("mod_stronghold")) {

	::Stronghold.VisualsMap["Barbarians"] <- {
		ID = "Barbarians",
		Name = "Barbarians",
		Author = "Overhype",
		WorldmapFigure = [
			"figure_wildman_02",
			"figure_wildman_02",
			"figure_wildman_02",
			"figure_wildman_02",
		]
		Base = [
			["world_wildmen_01", ""],
			["world_wildmen_01", ""],
			["world_wildmen_02", ""],
			["world_wildmen_03", ""]
		],
		Upgrading = [
			["world_wildmen_01", ""],
			["world_wildmen_01", ""],
			["world_wildmen_02", ""],
			["world_wildmen_03", ""]
		]
		Houses =  [
			["world_houses_03_01", "world_houses_03_01_light"]
		]
		Background = {
			UIBackgroundCenter = [
				"ui/settlements/barbhall_01",
				"ui/settlements/barbhall_01",
				"ui/settlements/barbhall_01",
				"ui/settlements/barbhall_01",
			]
			UIBackgroundLeft = [
				"ui/settlements/empty",
				"ui/settlements/empty",
				"ui/settlements/empty",
				"ui/settlements/empty",
			]
			UIBackgroundRight = [
				"ui/settlements/empty",
				"ui/settlements/empty",
				"ui/settlements/empty",
				"ui/settlements/empty",
			]
			UIRampPathway = [
				"ui/settlements/ramp_01_planks",
				"ui/settlements/ramp_01_planks",
				"ui/settlements/ramp_01_planks",
				"ui/settlements/ramp_01_planks",
			]
		}
	};

	::Stronghold.VisualsMap["BarbariansSnow"] <- {
		ID = "BarbariansSnow",
		Name = "Snow Barbarians",
		Author = "Overhype",
		Base = [
			["world_wildmen_01_snow", ""],
			["world_wildmen_01_snow", ""],
			["world_wildmen_02_snow", ""],
			["world_wildmen_03_snow", ""]
		],
		Upgrading = [
			["world_wildmen_01_snow", ""],
			["world_wildmen_01_snow", ""],
			["world_wildmen_02_snow", ""],
			["world_wildmen_03_snow", ""]
		]
		
	};

	::Stronghold.VisualsMap["BarbariansSnow"].WorldmapFigure <- clone ::Stronghold.VisualsMap["Barbarians"].WorldmapFigure
	::Stronghold.VisualsMap["BarbariansSnow"].Houses <- clone ::Stronghold.VisualsMap["Barbarians"].Houses
	::Stronghold.VisualsMap["BarbariansSnow"].Background <- clone ::Stronghold.VisualsMap["Barbarians"].Background
}

