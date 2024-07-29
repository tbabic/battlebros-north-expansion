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
		Script = "scripts/entity/tactical/humans/barbarian_wolf_marauder"
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

::NorthMod.Const.Spawn.StrongholdBarbarians <- [];
foreach(p in this.Const.World.Spawn.Barbarians)
{
	if (p.Troops[0].Type == this.Const.World.Spawn.Troops.BarbarianThrall)
	{
		continue;
	}
	::NorthMod.Const.Spawn.StrongholdBarbarians.push(p);
}



::NorthMod.Const.EnabledLogging <- true;
::NorthMod.Const.BarbarianNames <- [];
::NorthMod.Const.BarbarianNames.extend(this.Const.Strings.BarbarianNames);
::NorthMod.Const.BarbarianTitles <- [];
::NorthMod.Const.BarbarianTitles.extend(this.Const.Strings.BarbarianTitles);

::NorthMod.Const.BarbarianNames.extend(["Alfrun", "Ansgar","Askel","Bersi", "Birger", "Bodolf", "Brede", "Dagr", "Dreng", 
	"Eyvind","Gardi","Geirolf", "Gorm", "Gudmund", "Gunnbjorn","Gunnolf", "Hafnar", "Hrolf","Jolgeir", "Jorund", "Jostein",
	"Magnor", "Modolf", "Mord", "Njall", "Roar", "Rune","Rurik", "Sigbjorn", "Sten", "Skarde","Toke","Trygve", "Vegeir"
]);
	
::NorthMod.Const.BarbarianTitles.extend(["The Bear", "The Wolf", "The Bearclaw", "Giantborn", "Bonesmasher", "Skullsmasher",
	"Frostborn", "Iceblood", "Ironhead", "Thunderhead", "Skullsplitter", "Icebeard"]);

::NorthMod.Const.DuelChampions <- [];
::NorthMod.Const.DuelChampions.push({
	Level = 1,
	ID = this.Const.EntityType.BarbarianThrall,
	Script = "scripts/entity/tactical/humans/barbarian_thrall",
	Variant = 0,
	Chance = 60,
	MaxBroLevel = 4,
	Image = "ui/images/duel_thrall_image.png"
});

::NorthMod.Const.DuelChampions.push({
	Level = 2,
	ID = this.Const.EntityType.BarbarianMarauder,
	Script = "scripts/entity/tactical/humans/barbarian_marauder",
	Variant = 0,
	Chance = 30,
	MaxBroLevel = 7,
	Image = "ui/images/duel_reaver_image.png"
});

::NorthMod.Const.DuelChampions.push({
	Level = 3,
	ID = this.Const.EntityType.BarbarianChampion,
	Script = "scripts/entity/tactical/humans/barbarian_champion",
	Variant = 0,
	Chance = 30,
	MaxBroLevel = 11,
	Image = "ui/images/duel_chosen_image.png"
});

::NorthMod.Const.DuelChampions.push({
	Level = 4,
	ID = this.Const.EntityType.BarbarianChampion,
	Script = "scripts/entity/tactical/humans/barbarian_champion",
	Variant = 1,
	Chance = 20,
	MaxBroLevel = 100,
	Image = "ui/images/duel_champion_image.png"
});

::NorthMod.Const.Spawn <- {};
::NorthMod.Const.Spawn.BarbarianNoThralls <- [];
foreach ( s in Const.World.Spawn.Barbarians)
{
	local valid = true;
	foreach(t in s.Troops)
	{
		if(t.Type == this.Const.World.Spawn.Troops.BarbarianThrall)
		{
			valid = false;
			break;
		}
	}
	if (valid)
	{
		::NorthMod.Const.Spawn.BarbarianNoThralls.push(s);
	}
}


::NorthMod.Const.Skills <- [];
::NorthMod.Const.Skills.push({
	icon = "ui/icons/melee_skill.png",
	name = "Melee Skill",
	property = "MeleeSkill",
});
::NorthMod.Const.Skills.push({
	icon = "ui/icons/melee_defense.png",
	name = "Melee Defense",
	property = "MeleeDefense",
});
::NorthMod.Const.Skills.push({
	icon = "ui/icons/ranged_skill.png",
	name = "Ranged Skill",
	property = "RangedSkill"
});
::NorthMod.Const.Skills.push({
	icon = "ui/icons/ranged_defense.png",
	name = "Ranged Defense",
	property = "RangedDefense"
});
::NorthMod.Const.Skills.push({
	icon = "ui/icons/health.png",
	name = "Hitpoints",
	property = "Hitpoints"
});
::NorthMod.Const.Skills.push({
	icon = "ui/icons/fatigue.png",
	name = "Max Fatigue",
	property = "Stamina"
});
::NorthMod.Const.Skills.push({
	icon = "ui/icons/bravery.png",
	name = "Resolve",
	property = "Bravery"
});
::NorthMod.Const.Skills.push({
	icon = "ui/icons/initiative.png",
	name = "Initiative",
	property = "Initiative"
});