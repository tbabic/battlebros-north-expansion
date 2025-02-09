::NorthMod <- { ID = "mod_north_expansion",	Name = "North Expansion", Version = "0.7.3"};
::mods_registerMod(::NorthMod.ID, ::NorthMod.Version, ::NorthMod.Name);

//TODO: test traits
//TODO: extract utils and const
//TODO: logInfo comment out
//TODO: situation eager recruits, icon: perk13


::mods_queue(null, "mod_msu, >mod_avatar, >mod_stronghold", function()
{
	::NorthMod.Mod <- ::MSU.Class.Mod(::NorthMod.ID, ::NorthMod.Version, ::NorthMod.Name);
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
	
	::mods_registerCSS("nem_screens/nem_main.css");
	// register the screen using modhooks.
	::mods_registerJS("nem_screens/duel_circle_screen.js");

	// create a new sq screen and set it in our mod table.
	::NorthMod.Screens <- {};
	::NorthMod.Screens.DuelCircleScreen <- this.new("scripts/ui/nem_screens/duel_circle_screen");

	// register the screen to be connected.
	::MSU.UI.registerConnection(::NorthMod.Screens.DuelCircleScreen);
	
	
	
	local page = ::NorthMod.Mod.ModSettings.addPage("General");
	page.addRangeSetting("StartingCamps", 1, 1, 8, 1, "Barbarian camps discovered", "Number of barbarian camps discovered at the start of the game.");
	
	page.addRangeSetting("ThrallChance", 5, 0, 30, 5, "Thrall chance", "Chance of a barbarian with a 'thrall' trait appearing for hiring");
	page.addRangeSetting("ChosenChance", 10, 0, 30, 5, "Chosen chance", "Chance of a barbarian with a 'chosen' trait appearing for hiring");
	page.addBooleanSetting("PredefinedBros", false, "Predefined bros", "Unique bros, recruitable with events, will have predefined attributes and talents." );
	
});



