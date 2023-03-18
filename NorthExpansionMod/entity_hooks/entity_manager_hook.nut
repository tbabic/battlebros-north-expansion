::mods_hookBaseClass("entity/world/entity_manager", function(o) {
	local onWorldEntityDestroyed = ::mods_getMember(o, "onWorldEntityDestroyed");
	::mods_override(o, "onWorldEntityDestroyed", function(_entity, _isLocation) {
		onWorldEntityDestroyed(_entity, _isLocation);
		if (this.World.Assets.getOrigin().getID() == "scenario.barbarian_raiders" && this.World.Flags.get("NorthExpansionCivilLevel") <= 1)
		{
			local combatType = ::NorthMod.Const.CombatTypes.Other;
			local f = this.World.FactionManager.getFaction(this.World.Statistics.getFlags().getAsInt("LastCombatFaction"));
			
			if(f.getType() == this.Const.FactionType.Barbarians){
				combatType = ::NorthMod.Const.CombatTypes.Barbarians;
			}
			else if(!_isLocation && _entity.getFlags().get("IsMercenaries"))
			{
				combatType = ::NorthMod.Const.CombatTypes.Mercenaries;
			}
			else if (f.getType() == this.Const.FactionType.OrientalCityState){
				combatType = ::NorthMod.Const.CombatTypes.Southern;
			}
			else if(!_isLocation && this.String.contains(_entity.getName(), "Trading Caravan"))
			{
				combatType = ::NorthMod.Const.CombatTypes.Caravan;
			}
			else if(!_isLocation && this.String.contains(_entity.getName(), "Peasants"))
			{
				combatType = ::NorthMod.Const.CombatTypes.Peasants;
			}
			else if(f.getType() == this.Const.FactionType.Settlement)
			{
				combatType = ::NorthMod.Const.CombatTypes.Milita;
			}
			else if(f.getType() == this.Const.FactionType.Settlement)
			{
				combatType = ::NorthMod.Const.CombatTypes.Milita;
			}
			else if(f.getType() == this.Const.FactionType.Bandits)
			{
				combatType = ::NorthMod.Const.CombatTypes.Bandits;
			}
			else if(f.getType() == this.Const.FactionType.Noble)
			{
				combatType = ::NorthMod.Const.CombatTypes.Noble;
			}

			logInfo("combatType: " + combatType);
			this.World.Statistics.getFlags().set("NorthExpansionSurvivorType", combatType);
		}
	});
});