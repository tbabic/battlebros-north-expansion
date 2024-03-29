::NorthMod.Const <- {};
::NorthMod.Const.DisabledAmbitions1 <- [
	"ambition.allied_civilians",
	"ambition.allied_nobles",
	"ambition.battle_standard",
	"ambition.contracts",
	"ambition.defeat_holywar",
	"ambition.defeat_civilwar",
	"ambition.fulfill_x_southern_contracts",
	"ambition.make_nobles_aware",
	"ambition.sergeant",
	"ambition.trade",
	"ambition.visit_settlements",
	"ambition.ranged_mastery",
	"ambition.win_x_arena_fights"
	
];

::NorthMod.Const.DisabledAmbitions2 <- [
	"ambition.battle_standard",
	"ambition.sergeant",
	
];


::NorthMod.Const.CombatTypes <- {
	Barbarians = 1,
	Bandits = 2,
	Mercenaries = 3
	Nobles = 4,
	Militia = 5,
	Peasants = 6,
	Caravan = 7,
	Southern = 8
	Other = 0
}

::NorthMod.Const.Troop <- {};

::NorthMod.Const.Troop.BarbarianWolf <- {
		ID = this.Const.EntityType.Direwolf,
		Variant = 0,
		Strength = 25,
		Cost = 25,
		Row = 0,
		Script = "scripts/entity/tactical/humans/barbarian_marauder"
	}

::NorthMod.Const.Spawn <- {}

::NorthMod.Const.Spawn.BarbarianWolves <- [];

for(local i = 3; i<=30; i++)
{
	local troopType = ::NorthMod.Const.Troop.BarbarianWolf
	local cost = troopType.Cost * i;
	
	::NorthMod.Const.Spawn.BarbarianWolves.push({
		Cost = cost,
		MovementSpeedMult = 1.0,
		VisibilityMult = 1.0,
		VisionMult = 1.0,
		Body = "figure_werewolf_01",
		Troops = [
			{
				Type = troopType,
				Num = i
			}
		]
	});
}



::NorthMod.Const.EnabledLogging <- true;
::NorthMod.Const.BarbarianNames <- [];
::NorthMod.Const.BarbarianNames.extend(this.Const.Strings.BarbarianNames);
::NorthMod.Const.BarbarianTitles <- [];
::NorthMod.Const.BarbarianTitles.extend(this.Const.Strings.BarbarianTitles);

::NorthMod.Const.BarbarianNames.extend(["Ansgar","Askel","Birger", "Bodolf", "Brede", "Dreng", 
	"Eyvind","Gardi","Geirolf", "Gorm", "Gudmund", "Gunnbjorn","Gunnolf", "Hafnar", "Hrolf","Jolgeir", "Jorund", "Jostein",
	"Magnor", "Modolf", "Mord", "Njall", "Roar", "Rune","Rurik", "Sten", "Skarde","Toke","Trygve", "Vegeir"
]);
	
::NorthMod.Const.BarbarianTitles.extend(["The Bear", "The Wolf", "The Bearclaw", "Giantborn", "Bonesmasher", "Skullsmasher", "Frostborn", "Iceblood", "Ironhead", "Thunderhead", "Skullsplitter"]);