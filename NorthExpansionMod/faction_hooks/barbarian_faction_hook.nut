::mods_hookNewObject("factions/barbarian_faction", function(o) {
    
    ::mods_override(o, "isReadyForContract", function() {
        //TODO: barbairans ready for contract
        
        return true;
    });
    
});