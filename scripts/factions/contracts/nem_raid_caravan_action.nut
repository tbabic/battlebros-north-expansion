this.nem_raid_caravan_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		EnemyFaction = null,
		StartId = null,
		DestId = null
	},
	function create()
	{
		this.m.ID = "action.nem_raid_caravan";
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

		if (!_faction.isReadyForContract())
		{
			return;
		}
		
		
		potentialEnemies.extend.this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);
		potentialEnemies.extend.this.World.FactionManager.getFactionsOfType(this.Const.FactionType.OrientalCityState);
		
		local startSettlements = [];
		
		foreach(e in this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse))
		{
			local f = this.World.FactionManager.getFaction(e);
			startSettlements.extend(f.getSettlements());
		}
		local idx = -1;
		for (local i = 0; i < startSettlements.len(); i++)
		{
			if (startSettlements[i] == this.m.Faction){
				idx = i;
			}
		}
		
		startSettlements.remove(idx);
		local startIdx = this.Math.rand(0, startSettlements.len()-1);
		local start = startSettlements[startIdx];
		
		
		
		local enemyFaction == null;
		if (start.isMilitary())
		{
			enemyFaction = start.getOwner();
		}
		else if(start.isSouthern())
		{
			enemyFaction = start.getOwner();
		}
		else {
			local factionId = start.getFactionOfType(this.Const.FactionType.Settlement);
			if (factionId == null)
			{
				return;
			}
			local enemyFaction = this.World.FactionManager.getFaction(factionId);
		}
		
		
		
		local endSettlements = start.getTile();
		local candidateEnds = [];
		local playerTile = this.World.State.getPlayer().getTile();
		foreach (s in startSettlements)
		{
			if(s == start)
			{
				continue;
			}
			
			local distanceStart = this.getDistanceOnRoads(start.getTile(), s.getTile());
			local daysStart = this.getDaysRequiredToTravel(distanceStart, this.Const.World.MovementSettings.Speed * 0.6, true);
			
			local distancePlayer = start.getTile().getDistanceTo(playerTile);
			local daysPlayer = this.getDaysRequiredToTravel(distancePlayer, this.Const.World.MovementSettings.Speed * 1.0, true)
			if (daysPlayer > 1.5 * daysStart)
			{
				continue;
			}
			
			endSettlements.push(s);
		}
		if (endSettlements.len() == 0)
		{
			return;
		}
		
		local endIdx = this.Math.rand(0, endSettlements.len()-1);
		local end = endSettlements[endIdx];
		
		this.m.StartId = start.getID();
		this.m.EnemyFaction = enemyFaction.getID();
		this.m.DestId = end.getID();
		this.m.Score = 1;
	}

	function onClear()
	{
		this.m.StartId = null;
		this.m.DestId = null;
		this.m.EnemyFaction = null;
	}

	function onExecute( _faction )
	{
		local contract = this.new("scripts/contracts/contracts/nem_raid_caravan_contract");
		contract.setFaction(_faction.getID());
		contract.setEmployerID(_faction.getRandomCharacter().getID());
		contract.setCaravanInfo(this.m.EnemyFaction, this.m.StartId, this.m.DestId);
		this.World.Contracts.addContract(contract);
	}

});

