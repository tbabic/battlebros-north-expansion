::mods_hookNewObject("factions/barbarian_faction", function(o) {
    ::mods_override(o, "onUpdate", function()
	{
        logInfo("barbarians update: " + this);
        foreach (s in this.getSettlements()) {
            
            if(s.isReadyForContract())
            {
                s.createNewContract();
            }
        }
    });
});