
::mods_hookBaseClass("contracts/contract", function(o) {

	
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
	

});
