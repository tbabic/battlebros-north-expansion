::mods_hookNewObject("factions/barbarian_faction", function(o) {
    
    logInfo("barb faction override")
    ::mods_override(o, "onUpdate", function()
	{
        
        foreach (s in this.getSettlements()) {
            
            if(s.isReadyForContract())
            {
                s.createNewContract();
            }
        }
    });
    
});