this.b_raid_caravan_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		Enemy = null
	},
	function create()
	{
		this.m.ID = "action.b_raid_caravan";
		this.m.Cooldown = this.World.getTime().SecondsPerDay * 12;
		this.m.IsStartingOnCooldown = false;
		this.m.IsSettlementsRequired = true;
		this.faction_action.create();
	}

	function onUpdate( _faction )
	{
		if (!this.Const.DLC.Unhold)
		{
			return;
		}

		if (this.World.FactionManager.isGreaterEvil())
		{
			return;
		}

		if (!_faction.isReadyForContract())
		{
			return;
		}

		if (_faction.getPlayerRelation() <= 60)
		{
			return;
		}

		if (this.Math.rand(1, 100) > 10)
		{
			return;
		}

		local potentialEnemies = [];		
		local factions = clone this.World.FactionManager.getFactions(true);

		for( local i = 0; i < factions.len(); i = ++i )
		{
			logInfo("faction raid: " + faction[i].getName());
			if (factions[i] == null)
			{
				continue;
			}
			if (factions[i].getID() == _faction.getID())
			{
				continue;
			}
			else if (factions[i].getSettlements().len() < 1)
			{
				continue;
			}
			else if (_faction.isAlliedWith(factions[i].getID()))
			{
				logInfo("b_raid_caravan - allied with: " + factions[i].getName());
				continue;
			}
			local isolated = true;
			foreach(s in factions[i].getSettlements()) {
				if (!s.isIsolated()) {
					isolated = false;
					break;
				}
			}
			if (isolated) {
				continue;
			}
			logInfo("faction raid pushed: " + faction[i].getName());
			potentialEnemies.push(factions[i]);
		}
		
		if (potentialEnemies.len() == 0)
		{
			return;
		}

		this.m.Enemy = potentialEnemies[this.Math.rand(0, potentialEnemies.len() - 1)];
		this.m.Score = 1;
	}

	function onClear()
	{
		this.m.Enemy = null;
	}

	function onExecute( _faction )
	{
		local contract = this.new("scripts/contracts/contracts/b_raid_caravan_contract");
		contract.setFaction(_faction.getID());
		contract.setEmployerID(_faction.getRandomCharacter().getID());
		contract.setTargetFaction(this.m.Enemy);
		this.World.Contracts.addContract(contract);
	}

});

