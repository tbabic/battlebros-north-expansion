::mods_registerMod("mod_north_expansion", 0.1, "North Expansion");

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
}

::mods_queue(null, null, function()
{
	if(::mods_getRegisteredMod("mod_avatar")) {
		::AvatarMod.Const.ScenarioBackgrounds["scenario.barbarian_raiders"] <- { 
			Background = "barbarian_background",
			Description = "You were raised in the harsh north and fought many battles, mostly victorious but you've managed to live through few bitter defeats. But now it's time to find your destiny somewhere south. Working as a mercenary, doing what you do best, fighting, seems like the best way to go forward."
			StartingLevel = 3,
		};
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
				local r = this.Math.rand(1,100);
				if (r <= 60) {
					onAddEquipment();
				}
				if (r <= 90) {
					// thrall equipment
					local weapons = [
						"scripts/items/weapons/barbarians/antler_cleaver",
						"scripts/items/weapons/barbarians/claw_club",
						"scripts/items/weapons/militia_spear"
					];
					this.m.Items.equip(this.new("scripts/items/" + weapons[this.Math.rand(0, weapons.len() - 1)]));
					if (this.Math.rand(1, 100) <= 60)
					{
						local armor = [
							"scripts/items/armor/barbarians/thick_furs_armor",
							"scripts/items/armor/barbarians/animal_hide_armor"
						];
						local a = this.new("scripts/items/" + armor[this.Math.rand(0, armor.len() - 1)]);
						this.m.Items.equip(a);
					}
					if (this.Math.rand(1, 2) <= 1)
					{
						local helmet = [
							"scripts/items/helmets/barbarians/leather_headband",
							"scripts/items/helmets/barbarians/bear_headpiece"
						];
						this.m.Items.equip(this.new("scripts/items/" + helmet[this.Math.rand(0, helmet.len() - 1)]));
					}
					
					if (this.Math.rand(1, 100) <= 20)
					{
						this.m.Items.equip(this.new("scripts/items/shields/wooden_shield_old"));
					}
					
				} else {
					// chosen equipment
					local weapons = [
						"weapons/barbarians/rusty_warblade",
						"weapons/barbarians/heavy_rusty_axe",
						"weapons/barbarians/skull_hammer",
						"weapons/barbarians/two_handed_spiked_mace"
					];
					this.m.Items.equip(this.new("scripts/items/" + weapons[this.Math.rand(0, weapons.len() - 1)]));
					
					local armor = [
						"armor/barbarians/thick_plated_barbarian_armor",
						"armor/barbarians/rugged_scale_armor",
						"armor/barbarians/heavy_iron_armor"
					];
					local a = this.new("scripts/items/" + armor[this.Math.rand(0, armor.len() - 1)]);
					this.m.Items.equip(a);
					
					local helmet = [
						"helmets/barbarians/heavy_horned_plate_helmet",
						"helmets/barbarians/closed_scrap_metal_helmet",
						"helmets/barbarians/crude_faceguard_helmet"
					];
					this.m.Items.equip(this.new("scripts/items/" + helmet[this.Math.rand(0, helmet.len() - 1)]));
				}
			} else {
				onAddEquipment();
			}
		}
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
	
});



