if(::mods_getRegisteredMod("mod_stronghold")) {
    ::mods_hookExactClass("entity/world/settlements/stronghold_player_base", function(o) {
        this.logInfo("Hooking stronghold base");
        local _onVisualsChanged = ::mods_getMember(o, "onVisualsChanged");
        ::mods_override(o, "onVisualsChanged", function(newSprites) {
            _onVisualsChanged(newSprites);
            if (this.World.Flags.get("NorthExpansionActive"))
            {
                this.m.Buildings[6].updateSprite();
                                   
            }
        });
        
        local _onBuild = ::mods_getMember(o, "onBuild");
        ::mods_override(o, "onBuild", function() {
            this.logInfo("stronghold on build");
            if (this.World.Flags.get("NorthExpansionActive") && this.World.Flags.getAsInt("NorthExpansionCivilLevel") == 1 )
            {
                
                this.m.Spriteset = "Barbarians";
                if (this.Stronghold.isOnTile(this.getTile(), [this.Const.World.TerrainType.Snow])) {
                    this.m.Spriteset = "BarbariansSnow";
                }
            }
            _onBuild();
        });
        
    });
    
    ::mods_hookExactClass("factions/stronghold_player_faction", function(o) {
        this.logInfo("Hooking stronghold faction");
        local _spawnEntity = ::mods_getMember(o, "spawnEntity");
        ::mods_override(o, "spawnEntity", function(_tile, _name, _uniqueName, _template, _resources) {
            this.logInfo("spawn stronghold entity");
            if (this.World.Flags.get("NorthExpansionActive") && this.World.Flags.getAsInt("NorthExpansionCivilLevel") == 1)
            {
                this.logInfo("barbarian template");
                if (_template == this.Const.World.Spawn.Mercenaries)
                {
                    _template = ::NorthMod.Const.Spawn.StrongholdBarbarians;
                }
                _name = ::NorthMod.Utils.stringReplace(_name, "Mercenary", "Barbarian");
            }
            
            
            return _spawnEntity(_tile, _name, _uniqueName, _template, _resources);
            
        });
        
    });
}