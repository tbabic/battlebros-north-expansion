::mods_hookBaseClass("ambitions/ambition", function(o) {
	local onUpdateScore = ::mods_getMember(o, "onUpdateScore");
	::mods_override(o, "onUpdateScore", function() {
		if (this.World.Flags.get("NorthExpansionCivilActive") && this.World.Flags.get("NorthExpansionCivilLevel") <= 2)
		{
			local disabledAmbitions = ::NorthMod.Const.DisabledAmbitions1;
			if (this.World.Flags.get("NorthExpansionCivilLevel") == 2)
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