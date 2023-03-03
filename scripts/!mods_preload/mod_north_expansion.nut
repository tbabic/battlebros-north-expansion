::mods_registerMod("mod_north_expansion", 0.1, "North Expansion");

//TODO: test traits
//TODO: extract utils and const
//TODO: logInfo comment out
//TODO: situation eager recruits, icon: perk13



::NorthMod <- {};
::NorthMod.Utils <-{
	
	function stringSplit(sourceString, delimiter)
	{
		local leftover = sourceString;
		local results = [];
		while(true)
		{
			local index = leftover.find(delimiter);
			if (index == null) {
				results.push(leftover);
				break;
			}
			local leftSide = leftover.slice(0, index);
			results.push(leftSide);
			leftover = leftover.slice(index + delimiter.len());
		}
		return results;
	}

	function stringReplace( sourceString, textToReplace, replacementText )
	{
		local strings = this.stringSplit(sourceString, textToReplace);
		local result = strings[0];
		
		for (local i = 1; i < strings.len(); i++) {
			 result += replacementText + strings[i];
			 
		}
		return result;
	}
	
	function scorePicker(scores)
	{
		local totalScore = 0;
		for (local i = 0; i < totalScore.len(); i++)
		{
			totalScore += scores[i];
		}
		local r = this.Math.rand(1, totalScore);
		for (local i = 0; i < totalScore.len(); i++) {
			if (score[i] >= totalScore)
			{
				return i;
			}
			totalScore -= score[i];
		}
		return null;
	}
	
	
	function guaranteedTalents(bro, talent, number)
	{
	
		local talents = bro.getTalents();
		if (talents[talent] > 0 && talents[talent] < number )
		{
			talents[talent] = number;
		}
		else if (talents[talent] == 0) {
			local count = 0;
			local min = 10;
			local minTalent = null;
			for (local i = 0; i < talents.len(); i++) {
				if (talents[i] > 0) {
					count++;
					if (talents[i] < min && i != this.Const.Attributes.MeleeDefense) {
						min = talents[i];
						minTalent = i;
					}
				}
				
			}
			if(count < 3) {
				talents[this.Const.Attributes.MeleeSkill] = number;
			} else {
				talents[minTalent] = 0;
				talents[this.Const.Attributes.MeleeSkill] = number;
			}
		}
		
		
		
		bro.m.Attributes = [];
		bro.fillAttributeLevelUpValues(this.Const.XP.MaxLevelWithPerkpoints - 1);
	}
}

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
	"ambition.ranged_mastery"
	
];

::NorthMod.Const.DisabledAmbitions2 <- [
	"ambition.battle_standard",
	"ambition.sergeant",
	
];

::NorthMod.Const.FactionType <- {
	BarbarianSettlement = 100,
};



::mods_queue(null, null, function()
{
	if(::mods_getRegisteredMod("mod_avatar")) {
		::AvatarMod.Const.ScenarioBackgrounds["scenario.barbarian_raiders"] <- { 
			Background = "barbarian_background",
			Description = "You were born and raised in the harsh north. When you were just a boy, a witch of the north foretold you a great destiny, but mostly fighting raiding and pillaging. That destiny has brought you many victories and carried you through few defeats. However, a twist in the fate has now left you in command of other men. You are no longer the master of only your destiny."
			StartingLevel = 3,
			AlternativeBackgrounds = ["wildman_background", "raider_background"],
			Traits = ["scripts/skills/traits/destined_trait", "scripts/skills/traits/champion_trait"]
		};
		
		::AvatarMod.Const.TraitCosts["trait.destined"] <- 50;
		::AvatarMod.Const.TraitCosts["trait.champion"] <- 50;
		
		/* local newTraits = [];
		newTraits.push(
		[
			"trait.destined",
			"scripts/skills/traits/destined_trait"
		]);
		
		newTraits.push(
		[
			"trait.champion",
			"scripts/skills/traits/champion_trait"
		]);
		
		
		::AvatarMod.AvatarManager.addAdditionalTraits(newTraits); */
		
		//TODO: add new traits to avatar mod
	}
	else {
		logInfo("avatarMod not registered")
	}
	::mods_hookClass("skills/backgrounds/barbarian_background", function(o) {
		::mods_override(o, "onBuildDescription", function() {
			if (this.World.Assets.getOrigin().getID() == "scenario.barbarian_raiders")
			{
				return "{Some men are born to be fight. Well over six feet tall and with arms the size of trees, %name% is definitely one of them. | %name%\'s shadow casts over smaller men - and they seem to only further shrink when he walks by. | When his family was slaughtered, newborn %name% was taken in by the very barbarians who did it. | Years of brutal combat with his equally tough clansmen left %name% a scarred and scary figure. | %name% decided many years ago to take by force from the weak and feeble whatever he desired, and has made his presence known by raiding caravans and villages ever since.} {The barbarian has spent many years raiding and pillaging, but with meager profits. | Exiled from the clan for disagreeing with the chief, the barbarian has wandered for years, doing whatever work for whatever coin. | When in the heat of battle he cleaved five men with one swing, three of which were his clansment, the barbarian was sent away from his tribe. | When he fought in the single combat as a champion for his tribe, barbarian didn't expect he would be betrayed. He slaughtered his chieftain and then left towards south. | The barbarian has spent many nights sleeping peacefully beneath a pale moon - and just as many days killing ruthlessly beneath a shining sun. | A devoted believer in the old ways, %name% desires to die a glorious warrior\'s death to take his place beside the gods. But slaughtering villagers like cattle won\'t get the attention of the gods, and so he now looks for a greater challenge. | It started with a good raid on a merchant caravan. The few guards were quickly cut down and the fleeing merchant didn\'t run fast enough - a javelin to his back attested to it. The spoils were rich, but before long there was heated argument about how they were to be shared. By evening, most of the raiders had killed each other. %name% only barely escaped and had nothing to show for his day but a limping leg.} {Always on the hunt for more loot, the company of other northmen seemed like a good fit. | Too terrifying to be employed for long, %name% seeks the company of men who will not piss themselves when he grabs a weapon. | Tired of killing women and children, %name% sees mercenary work as something worthy of his skill. | The man is not kind in the least, but he can wield a weapon like it\'s one of his missing fingers.}";
			} else {
				return "{%name% survived the battle between yourself and his own tribe of warriors. He offered himself to your company or to your sword. Impressed by his bravery, you chose to take him in. A foreign brute, he hardly speaks your native tongue and he is not well liked by the rest of the company. But if anything can bond two men it is fighting beside one another, killing when it counts, and drinking the night away at the tavern.}";
			}
			
		});
		local onAddEquipment = ::mods_getMember(o, "onAddEquipment");
		::mods_override(o, "onAddEquipment", function() {
			if (this.World.Assets.getOrigin().getID() == "scenario.barbarian_raiders") {
				logInfo("barb equipment:" + this.getID());
				local items = this.getContainer().getActor().getItems();
				local r = this.Math.rand(1,100);
				if (r <= 60) {
					onAddEquipment();
				}
				if (r <= 90) {
					// thrall equipment
					local weapons = [
						"weapons/barbarians/antler_cleaver",
						"weapons/barbarians/claw_club",
						"weapons/militia_spear"
					];
					items.equip(this.new("scripts/items/" + weapons[this.Math.rand(0, weapons.len() - 1)]));
					if (this.Math.rand(1, 100) <= 60)
					{
						local armor = [
							"armor/barbarians/thick_furs_armor",
							"armor/barbarians/animal_hide_armor"
						];
						local a = this.new("scripts/items/" + armor[this.Math.rand(0, armor.len() - 1)]);
						items.equip(a);
					}
					if (this.Math.rand(1, 2) <= 1)
					{
						local helmet = [
							"helmets/barbarians/leather_headband",
							"helmets/barbarians/bear_headpiece"
						];
						items.equip(this.new("scripts/items/" + helmet[this.Math.rand(0, helmet.len() - 1)]));
					}
					
					if (this.Math.rand(1, 100) <= 20)
					{
						items.equip(this.new("scripts/items/shields/wooden_shield_old"));
					}
					
				} else {
					// chosen equipment
					local weapons = [
						"weapons/barbarians/rusty_warblade",
						"weapons/barbarians/heavy_rusty_axe",
						"weapons/barbarians/skull_hammer",
						"weapons/barbarians/two_handed_spiked_mace"
					];
					items.equip(this.new("scripts/items/" + weapons[this.Math.rand(0, weapons.len() - 1)]));
					
					local armor = [
						"armor/barbarians/thick_plated_barbarian_armor",
						"armor/barbarians/rugged_scale_armor",
						"armor/barbarians/heavy_iron_armor"
					];
					local a = this.new("scripts/items/" + armor[this.Math.rand(0, armor.len() - 1)]);
					items.equip(a);
					
					local helmet = [
						"helmets/barbarians/heavy_horned_plate_helmet",
						"helmets/barbarians/closed_scrap_metal_helmet",
						"helmets/barbarians/crude_faceguard_helmet"
					];
					items.equip(this.new("scripts/items/" + helmet[this.Math.rand(0, helmet.len() - 1)]));
				}
			} else {
				onAddEquipment();
			}
		});
	});
	
	::mods_hookClass("contracts/contracts/drive_away_barbarians_contract", function(o) {
		local onHomeSet = ::mods_getMember(o, "onHomeSet");
		if (onHomeSet == null) {
			logInfo("missing onHomeSet");
		}
		::mods_override(o, "onHomeSet", function() {		
			if (this.m.SituationID == 0)
			{	
				logInfo("drive away barbarians override");
				local script = "scripts/entity/world/settlements/situations/ambushed_trade_routes_situation";
				local faction = this.World.FactionManager.getFaction(this.m.Faction);
				if (faction.getFlags().get("IsBarbarianFaction"))
				{
					local script = "scripts/entity/world/settlements/situations/raided";
				}
				this.m.SituationID = this.m.Home.addSituation(this.new(script));
			}
		});
	});
	
	::mods_hookClass("contracts/contracts/drive_away_bandits_contract", function(o) {
		local onHomeSet = ::mods_getMember(o, "onHomeSet");
		if (onHomeSet == null) {
			logInfo("missing onHomeSet");
		}
		::mods_override(o, "onHomeSet", function() {		
			if (this.m.SituationID == 0)
			{	
				logInfo("drive away bandits override");
				local script = "scripts/entity/world/settlements/situations/ambushed_trade_routes_situation";
				local faction = this.World.FactionManager.getFaction(this.m.Faction);
				if (faction.getFlags().get("IsBarbarianFaction"))
				{
					local script = "scripts/entity/world/settlements/situations/raided";
				}
				this.m.SituationID = this.m.Home.addSituation(this.new(script));
			}
		});
	});
	
	::mods_hookBaseClass("contracts/contract", function(o) {
		local getScreen = ::mods_getMember(o, "getScreen");
		::mods_override(o, "getScreen", function(_id) {
			local screen = getScreen(_id);
			logInfo("contract:" + this.getID() + ";" + this.getName());
			local f = this.World.FactionManager.getFaction(this.m.Faction);
			if (f== null) {
				return screen;
			}
			if (screen != null && this.World.FactionManager.getFaction(this.m.Faction).getFlags().get("IsBarbarianFaction")) {
				local newText = screen.Text;
				newText = ::NorthMod.Utils.stringReplace(newText, "mercenary", "warrior");
				newText = ::NorthMod.Utils.stringReplace(newText, "Mercenary", "Warrior");
				newText = ::NorthMod.Utils.stringReplace(newText, "mercenaries", "warriors");
				newText = ::NorthMod.Utils.stringReplace(newText, "Mercenaries", "Warriors");
				newText = ::NorthMod.Utils.stringReplace(newText, "sellsword", "warrior");
				newText = ::NorthMod.Utils.stringReplace(newText, "Sellsword", "Warrior");
				screen.Text = newText;
			}
			return screen;
			
		});
	});
	
	::mods_hookClass("contracts/contracts/drive_away_barbarians_contract", function(o) {
		local duelScreen = null;
		
		foreach( s in o.m.Screens )
		{
			if (s.ID == "TheDuel1")
			{
				duelScreen = s;
			}
		}

		local start = duelScreen.start;
		::mods_override(duelScreen, "start", function() {
			start();
			if (this.World.Assets.getOrigin().getID() != "scenario.barbarian_raiders") {
				return;
			}
			local brothers = this.World.getPlayerRoster().getAll();
			local champion;
			local avatar;
			foreach( bro in raw_roster )
			{
				if (bro.getSkills().getSkillByID("trait.champion"))
				{
					champion = bro;
				}
				
				if (bro.getFlags().get("IsPlayerCharacter") || bro.getFlags().get("IsPlayerCharacterAvatar"))
				{
					avatar = bro;
				}
			}
			local optionToModify = this.Options.len()-1;
			for( local i = 0; i < this.Options.len(); i++) {
				if (this.Options[i].Text == champion.getName() + " will fight your champion!")
				{
					optionToModify = i;
				}
				if (this.Options[i].Text == avatar.getName() + " will fight your champion!")
				{
					this.Options[i].Text = "I, " + this.Options[i].Text;
				}
			}
			local text = champion.getName() + " is my champion and he will win!";
			if (champion.getFlags().get("IsPlayerCharacter") || champion.getFlags().get("IsPlayerCharacterAvatar"))
			{
				text = "I, " + champion.getName() + ", will fight your champion and win!"
			}
			
			this.Options[optionToModify] = {
				Text = text,
				function getResult() {
					this.Flags.set("ChampionBrotherName", champion.getName());
					this.Flags.set("ChampionBrother", champion.getID());
					return "TheDuel2";
				}
			}
		});
		
	});
	
	::mods_hookBaseClass("entity/tactical/player", function(o) {
		local onInit = ::mods_getMember(o, "onInit");
		::mods_override(o, "onInit", function() {
			onInit();
			if (this.World.Assets.getOrigin().getID() == "scenario.barbarian_raiders")
			{
				this.m.Skills.add(this.new("scripts/skills/effects/skald_horn_effect"));
			}
		});
	});
	
	::mods_hookBaseClass("ambitions/ambition", function(o) {
		local onUpdateScore = ::mods_getMember(o, "onUpdateScore");
		::mods_override(o, "onUpdateScore", function() {
			if (this.World.Assets.getOrigin().getID() == "scenario.barbarian_raiders" && this.World.Statistics.getFlags().get("NorthExpansionCivilLevel") <= 2)
			{
				local disabledAmbitions = ::NorthMod.Const.DisabledAmbitions1;
				if (this.World.Statistics.getFlags().get("NorthExpansionCivilLevel") == 2)
				{
					local disabledAmbitions = ::NorthMod.Const.DisabledAmbitions2;
				}
				if (disabledAmbitions.find(this.m.ID) != null)
				{
					logInfo("ambition blocked - " + this.m.ID);
					return;
				}
				
			}
			logInfo("ambition proceed - " + this.m.ID);
			onUpdateScore();
			logInfo("ambition - " + this.m.ID + " = " + this.m.Score);
		});
	});
	
	::mods_hookBaseClass("factions/faction", function(o) {
		local normalizeRelation = ::mods_getMember(o, "normalizeRelation");
		::mods_override(o, "normalizeRelation", function() {
			//logInfo("normalize relations:" + this.getName());
			if (this.getFlags().get("IsBarbarianFaction"))
			{
				normalizeRelation();
				return;
			}
			else if (this.World.Assets.getOrigin().getID() != "scenario.barbarian_raiders" )
			{
				normalizeRelation();
				return;
			}
			else if(this.World.Statistics.getFlags().get("NorthExpansionCivilLevel") >= 2)
			{
				normalizeRelation();
				return;
			}
			else if (this.World.Ambitions.hasActiveAmbition() && this.World.Ambitions.getActiveAmbition().getID() == "ambition.make_civil_friends")
			{
				normalizeRelation();
				return;
			}
			//logInfo("normalize relations:" + this.getName() + " disabled" );
		});
	});
	
	::mods_hookClass("factions/faction_manager", function(o) {
		local makeEveryoneFriendlyToPlayer = ::mods_getMember(o, "makeEveryoneFriendlyToPlayer");
		::mods_override(o, "makeEveryoneFriendlyToPlayer", function() {
			logInfo("make friendly relations");
			if(this.World.Assets.getOrigin().getID() == "scenario.barbarian_raiders" && this.World.Statistics.getFlags().get("NorthExpansionCivilLevel") <= 1)
			{
				logInfo("make friendly relations disabled");
				return;
			}
			makeEveryoneFriendlyToPlayer();
			
			
		});
	});
	
	::mods_hookClass("entity/world/locations/barbarian_camp_location", function(o) {
		o.setOnCombatWithPlayerCallback(function(_location){
			local event = this.World.Events.getEvent("event.barbarian_duel");
			event.m.Location = _location;
			if(event.isValid())
			{
				this.World.Events.fire("event.barbarian_duel");
			}
		})
	});
	
	::mods_hookClass("entity/world/locations/barbarian_camp_location", function(o) {
		o.setOnCombatWithPlayerCallback(function(_location){
			local event = this.World.Events.getEvent("event.barbarian_duel");
			event.m.Location = _location;
			if(event.isValid())
			{
				this.World.Events.fire("event.barbarian_duel");
			}
		})
	});
	
	::mods_hookClass("entity/world/locations/barbarian_shelter_location", function(o) {
		o.setOnCombatWithPlayerCallback(function(_location){
			local event = this.World.Events.getEvent("event.barbarian_duel");
			event.m.Location = _location;
			if(event.isValid())
			{
				this.World.Events.fire("event.barbarian_duel");
			}
		})
	});
	
	
	//TODO: delete because of logging
	::mods_hookBaseClass("events/event", function(o) {
		local onUpdateScore = ::mods_getMember(o, "onUpdateScore");
		::mods_override(o, "onUpdateScore", function() {
			onUpdateScore();
			if(this.m.Score > 0) {
				logInfo("event - " + this.m.ID + " = " + this.m.Score);
			}
			
		});
	});

	
});



