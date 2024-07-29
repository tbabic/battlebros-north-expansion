::mods_hookClass("skills/backgrounds/barbarian_background", function(o) {
	::mods_override(o, "onBuildDescription", function() {
		if (this.World.Flags.get("NorthExpansionActive"))
		{
			return "{Some men are born to be fight. Well over six feet tall and with arms the size of trees, %name% is definitely one of them. | %name%\'s shadow casts over smaller men - and they seem to only further shrink when he walks by. | When his family was slaughtered, newborn %name% was taken in by the very barbarians who did it. | Years of brutal combat with his equally tough clansmen left %name% a scarred and scary figure. | %name% decided many years ago to take by force from the weak and feeble whatever he desired, and has made his presence known by raiding caravans and villages ever since.} {The barbarian has spent many years raiding and pillaging, but with meager profits. | Exiled from the clan for disagreeing with the chief, the barbarian has wandered for years, doing whatever work for whatever coin. | When in the heat of battle he cleaved five men with one swing, three of which were his clansmen, the barbarian was sent away from his tribe. | When he fought in the single combat as a champion for his tribe, barbarian didn't expect he would be betrayed. He slaughtered his chieftain and then left towards south. | The barbarian has spent many nights sleeping peacefully beneath a pale moon - and just as many days killing ruthlessly beneath a shining sun. | A devoted believer in the old ways, %name% desires to die a glorious warrior\'s death to take his place beside the gods. But slaughtering villagers like cattle won\'t get the attention of the gods, and so he now looks for a greater challenge. | It started with a good raid on a merchant caravan. The few guards were quickly cut down and the fleeing merchant didn\'t run fast enough - a javelin to his back attested to it. The spoils were rich, but before long there was heated argument about how they were to be shared. By evening, most of the raiders had killed each other. %name% only barely escaped and had nothing to show for his day but a limping leg.} {Always on the hunt for more loot, the company of other northmen seemed like a good fit. | Too terrifying to be employed for long, %name% seeks the company of men who will not piss themselves when he grabs a weapon. | Tired of killing women and children, %name% sees mercenary work as something worthy of his skill. | The man is not kind in the least, but he can wield a weapon like it\'s one of his missing fingers.}";
		} else {
			return "{%name% survived the battle between yourself and his own tribe of warriors. He offered himself to your company or to your sword. Impressed by his bravery, you chose to take him in. A foreign brute, he hardly speaks your native tongue and he is not well liked by the rest of the company. But if anything can bond two men it is fighting beside one another, killing when it counts, and drinking the night away at the tavern.}";
		}
		
	});
	
	
	local onAddEquipment = ::mods_getMember(o, "onAddEquipment");
	::mods_override(o, "onAddEquipment", function() {
		if (!this.World.Flags.get("NorthExpansionActive")) {
			onAddEquipment();
			return;
		}
		
		logInfo("barb equipment:" + this.getID());
		local items = this.getContainer().getActor().getItems();
		local r = this.Math.rand(1,100);
		

		if (this.getContainer().getSkillByID("trait.thrall") != null) {
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
			
		}
		else if (this.getContainer().getSkillByID("trait.chosen") != null)
		{	
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
		else
		{
			onAddEquipment();
		}
		
	});
	
	local onAdded = ::mods_getMember(o, "onAdded");
	::mods_override(o, "onAdded", function() {
		if(this.World.Assets.getOrigin()== null || !this.World.Flags.get("NorthExpansionActive"))
		{
			onAdded();
			return;
		}
		else {
			local actor = this.getContainer().getActor();
			if (this.m.IsNew)
			{
				actor.setName(::NorthMod.Utils.barbarianNameOnly());
			}

			if (this.m.IsNew && !(("State" in this.Tactical) && this.Tactical.State != null && this.Tactical.State.isScenarioMode()))
			{
				local r = this.Math.rand(1, 100);
				local thrallThreshold = ::NorthMod.Mod.ModSettings.getSetting("ThrallChance").getValue();
				local chosenThreshold = thrallThreshold + ::NorthMod.Mod.ModSettings.getSetting("ChosenChance").getValue();
				
				if (r <= thrallThreshold && bro.getFlags().get("nem_allow_thrall"))
				{
					actor.getSkills().add(this.new("scripts/skills/traits/thrall_trait"));
				}
				else if (r <= chosenThreshold && bro.getFlags().get("nem_allow_chosen"))
				{
					actor.getSkills().add(this.new("scripts/skills/traits/chosen_trait"));
				}
				else if (actor.getTitle() == "" && this.Math.rand(0, 3) == 3)
				{
					actor.setTitle(::NorthMod.Utils.barbarianTitle());
				}
			}
			
			this.character_background.onAdded();
		}
	});
});