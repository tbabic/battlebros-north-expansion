
::mods_hookBaseClass("contracts/contract", function(o) {

	// hook text changes to reflavor
	local getScreen = ::mods_getMember(o, "getScreen");
	::mods_override(o, "getScreen", function(_id) {
		local screen = getScreen(_id);
		logInfo("contract:" + this.getID() + ";" + this.getName());
		local f = this.World.FactionManager.getFaction(this.m.Faction);
		if (f== null) {
			return screen;
		}
		if (screen != null && f.getType() == this.Const.FactionType.Barbarians) {
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
	
	// hook settlement intro
	local onImportIntro = :: mods_getMember(o, "onImportIntro");
	::mods_override(o, "onImportIntro", function() {
		if (this.World.FactionManager.getFaction(this.m.Faction).getType() != this.Const.FactionType.Barbarians)
		{
			onImportIntro();
			return;
		}
		::NorthMod.ContractUtils.importSettlementIntro(this);
	
	});
	
	::mods_override(o, "isValid", function() {
		if (!this.m.IsValid)
		{
			logInfo("this.m.IsValid")
			return false;
		}

		if (this.Tactical.getEntityByID(this.m.EmployerID) == null)
		{
			logInfo("entity: " + this.m.EmployerID);
			logInfo("entity: " + this.Tactical.getEntityByID(this.m.EmployerID));
			return false;
		}

		if (this.World.FactionManager.getFaction(this.getFaction()).getSettlements().len() == 0)
		{
			logInfo("settlements: " + this.World.FactionManager.getFaction(this.getFaction()).getSettlements().len());
			return false;
		}

		if (this.m.Home != null && (this.m.Home.isNull() || !this.m.Home.isAlive()))
		{
			logInfo("home: " + this.m.Home);
			return false;
		}

		if (this.m.Origin != null && (this.m.Origin.isNull() || !this.m.Origin.isAlive()))
		{
			logInfo("origin: " + this.m.Origin);
			return false;
		}

		return this.onIsValid();
	
	});
	

});
