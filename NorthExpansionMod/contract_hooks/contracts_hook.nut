
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
		if (screen != null && this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians) != _faction) {
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
		if (!this.World.FactionManager.getFaction(this.m.Faction) == this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians))
		{
			onImportIntro();
			return;
		}
		::NorthMod.ContractUtils.importSettlementIntro(this);
	
	});
	

});
