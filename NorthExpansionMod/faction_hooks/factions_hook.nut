::mods_hookBaseClass("factions/faction", function(o) {
	local normalizeRelation = ::mods_getMember(o, "normalizeRelation");
	::mods_override(o, "normalizeRelation", function() {
		//logInfo("normalize relations:" + this.getName());
		
		if(this.World.Flags.get("NorthExpansionCivilLevel") >= 2)
		{
			normalizeRelation();
			return;
		}
		else if(this.World.Flags.get("NorthExpansionCivilLevel") >= 2)
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
		if(this.World.Flags.get("NorthExpansionActive") && this.World.Flags.get("NorthExpansionCivilLevel") <= 1)
		{
			logInfo("make friendly relations disabled");
			return;
		}
		makeEveryoneFriendlyToPlayer();
		
		
	});
});