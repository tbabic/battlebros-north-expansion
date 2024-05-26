::mods_registerMod("mod_north_expansion", 0.1, "North Expansion");

//TODO: test traits
//TODO: extract utils and const
//TODO: logInfo comment out
//TODO: situation eager recruits, icon: perk13



::NorthMod <- {};


::mods_queue(null, ">mod_avatar, !mod_stronghold(>=2)", function()
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
		
	}
	else {
		logInfo("avatarMod not registered")
	}
	
	local scriptFiles = this.IO.enumerateFiles("NorthExpansionMod/");

	foreach( scriptFile in scriptFiles )
	{
		logInfo(scriptFile);
		this.include(scriptFile);
	}
	
});



