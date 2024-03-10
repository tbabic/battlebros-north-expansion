::mods_hookNewObject("factions/barbarian_faction", function(o) {
    
    logInfo("barb faction override")
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
    
    ::mods_override(o, "addContract", function(_c)
	{
        logInfo("adding contract");
        _c.setFaction(this.getID());
		this.m.Contracts.push(_c);
    });
    
    ::mods_override(o, "isReadyForContract", function() {
        //TODO: barbairans ready for contract
        
        return true;
    });
    
});