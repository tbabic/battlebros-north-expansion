this.nem_raid_caravan_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		EnemyFaction = null,
		StartId = null,
		DestId = null,
		Home = null
	},
	function create()
	{
		this.m.ID = "action.nem_raid_caravan";
		this.m.Cooldown = this.World.getTime().SecondsPerDay * 12;
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
		if (!this.Const.DLC.Unhold)
		{
			return;
		}
		
		if (_faction.getType() != this.Const.FactionType.Barbarians)
		{
			return;
		}

		if (!_faction.isReadyForContract())
		{
			return;
		}
		this.logInfo("check: " + this.m.ID);
		
		this.m.Score = 1;
	}

	function onClear()
	{
		this.m.StartId = null;
		this.m.DestId = null;
		this.m.EnemyFaction = null;
	}
	
	function getDistanceOnRoads( _start, _dest )
	{
		local navSettings = this.World.getNavigator().createSettings();
		navSettings.ActionPointCosts = this.Const.World.TerrainTypeNavCost;
		navSettings.RoadMult = 0.2;
		navSettings.RoadOnly = true;
		local path = this.World.getNavigator().findPath(_start, _dest, navSettings, 0);

		if (!path.isEmpty())
		{
			return path.getSize();
		}
		else
		{
			return _start.getDistanceTo(_dest);
		}
	}
	
	function getDaysRequiredToTravel( _numTiles, _speed, _onRoadOnly )
	{
		local speed = _speed * this.Const.World.MovementSettings.GlobalMult;

		if (_onRoadOnly)
		{
			speed = speed * this.Const.World.MovementSettings.RoadMult;
		}

		local seconds = _numTiles * 170.0 / speed;

		if (seconds / this.World.getTime().SecondsPerDay > 1.0)
		{
			seconds = seconds * 1.1;
		}

		return this.Math.max(1, this.Math.round(seconds / this.World.getTime().SecondsPerDay));
	}
	
	function chooseCaravanRoute()
	{
		local allSettlements = this.World.EntityManager.getSettlements();
		
		local candidates = [];
		local playerTile = this.World.State.getPlayer().getTile();
		local startSettlements = [];
		local allSettlements = this.World.EntityManager.getSettlements();
		
		local southY = this.World.getMapSize().Y * 0.5;
		foreach(i, startCandidate in allSettlements)
		{
			local candidate = {
				startIdx = i,
				endIdxs	= []
			};
			
			foreach(j, endCandidate in allSettlements)
			{
				if(startCandidate == endCandidate)
				{
					continue;
				}
				
				if (startCandidate.getTile().Coords.Y < southY && endCandidate.getTile().Coords.Y < southY)
				{
					continue;
				}
				local distanceCaravan = this.getDistanceOnRoads(startCandidate.getTile(), endCandidate.getTile());
				local daysCaravan = this.getDaysRequiredToTravel(distanceCaravan, this.Const.World.MovementSettings.Speed * 0.6, true)
				
				local distancePlayer = endCandidate.getTile().getDistanceTo(playerTile);
				local daysPlayer = this.getDaysRequiredToTravel(distancePlayer, this.Const.World.MovementSettings.Speed * 1.0, true)
				
				if (daysPlayer > 1.5 * daysCaravan)
				{
					continue;
				}

				candidate.endIdxs.push(j);
				
				
			}
			if (candidate.endIdxs.len() > 0)
			{
				candidates.push(candidate);
			}
		}
		
		if(candidates.len() == 0)
		{
			return;
		}
		
		local candidateIdx = this.Math.rand(0, candidates.len()-1);
		local startIdx = candidates[candidateIdx].startIdx;
		local endIdx = this.Math.rand(0, candidates[candidateIdx].endIdxs.len()-1)
		local start = allSettlements[startIdx];
		local end = allSettlements[endIdx];
		
		
		local enemyFaction = null;
		if (start.isMilitary())
		{
			enemyFaction = start.getOwner();
		}
		else if(start.isSouthern())
		{
			enemyFaction = start.getOwner();
		}
		else {
			enemyFaction = start.getFactionOfType(this.Const.FactionType.Settlement);
			if (enemyFaction == null)
			{
				return;
			}
		}
		
		this.m.StartId = start.getID();
		this.m.EnemyFaction = enemyFaction.getID();
		this.m.DestId = end.getID();
	}

	function onExecute( _faction )
	{
		
		this.chooseCaravanRoute();
		if (this.m.StartId == null || this.m.DestId == null || this.m.EnemyFaction == null)
		{
			return;
		}
		local contract = this.new("scripts/contracts/contracts/nem_raid_caravan_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(this.m.Home); //TODO: check this
		contract.setEmployerID(this.m.Home.getChieftain().getID());
		contract.setCaravanInfo(this.m.EnemyFaction, this.m.StartId, this.m.DestId);
		this.World.Contracts.addContract(contract);
	}

});

