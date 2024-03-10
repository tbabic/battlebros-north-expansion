this.nem_hunting_raiders_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		EnemyFaction = null,
		Home = null
	},
	function create()
	{
		this.m.ID = "nem_hunting_raiders_action";
		this.m.Cooldown = this.World.getTime().SecondsPerDay * 7;
		this.m.IsStartingOnCooldown = false;
		this.m.IsSettlementsRequired = true;
		this.faction_action.create();
	}
	
	function setHome( _home)
	{
		this.m.Home = _home;
	}

	function onUpdate( _faction )
	{
		if (!_faction.isReadyForContract())
		{
			return;
		}
		
		if (_faction.getType() != this.Const.FactionType.Barbarians)
		{
			return;
		}


		if (this.World.Assets.getBusinessReputation() < 500)
		{
			return;
		}
		this.logInfo("check: " + this.m.ID);
		local myTile = this.m.Home.getTile();
		
		local factionTypes = [];
		factionTypes.push(this.Const.FactionType.Barbarians);
		factionTypes.push(this.Const.FactionType.Bandits);
		factionTypes.push(this.Const.FactionType.Zombies);
		if(!this.World.FactionManagerFactionManager.isGreaterEvil() || this.math.rand(1, 100))
		{
			factionTypes.push(this.Const.FactionType.NobleHouse);
		}
		if (this.World.FactionManagerFactionManager.isGreenskinInvasion() || this.Math.rand(1, 100) <= 10)
		{
			factionTypes.push(this.Const.FactionType.Orcs);
			factionTypes.push(this.Const.FactionType.Goblins);
		}
		
		
		local potentialEnemies = [];
		foreach(ft in factionTypes)
		{
			local enemies = this.getEnemyFactionsWithinDistance(myTile, ft, 20);
			potentialEnemies.extend(enemies);
		}
		
		
		local enemyFaction = potentialEnemies[this.Math.rand(0, potentialEnemies.len()-1)];
		this.m.EnemyFaction = enemyFaction.getID();
		this.m.Score = 1;
	}

	function getEnemyFactionsWithinDistance(_tile, _factionType, _distance)
	{
		local foundFactions = [];
		local factions = this.World.FactionManager.getFactionsOfType(_factionType);
		foreach (f in factions)
		{
			if (this.isWithinDistance(myTile, f ,20) && !f.isAlliedWithPlayer())
			{
				foundFactions.push(f);
			}
		}
		return foundFactions;
	}
	
	function isWithinDistance(_tile, _faction, _distance)
	{
		local locations = _faction.getSettlements();
		foreach( loc in locations )
		{
			if (_tile.getDistanceTo(loc.getTile()) <= _distance)
			{
				return true;
			}
		}
		return false;
	}
	
	function closestSettlement(_tile, _faction)
	{
		local lowestDistance = 9999;
		local locations = _faction.getSettlements();
		local found = null;
		foreach( loc in locations )
		{
			if (_tile.getDistanceTo(loc.getTile()) <= lowestDistance)
			{
				found = loc;
			}
		}
		return found;
	}
	
	function onClear()
	{
		this.m.EnemyFaction = null;
	}

	function onExecute( _faction )
	{
		local contract = this.new("scripts/contracts/contracts/nem_hunting_raiders_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(this.m.Home);
		contract.setEmployerID(this.m.Home.getChieftain());
		contract.setEnemyFaction(this.m.EnemyFaction);
		this.World.Contracts.addContract(contract);
	}

});

