this.nem_barbarian_king_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		Home = null
	},
	function create()
	{
		this.m.ID = "nem_barbarian_king_action";
		this.m.Cooldown = this.World.getTime().SecondsPerDay * 30;
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
		if (!this.Const.DLC.Wildmen || this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians) == null)
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

		if (_faction.getPlayerRelation() <= 25)
		{
			return;
		}

		if (this.World.Assets.getBusinessReputation() < 1400)
		{
			return;
		}
		
		
		this.logInfo("check: " + this.m.ID);
		
		local settlements = _faction.getSettlements();
		local barbarians = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians).getSettlements();
		local lowestDistance = 9999;
		local lowestDistanceSettlement;
		local found = false;
	
		foreach( b in barbarians )
		{
			if (b == this.m.Home || b.isLocationType(this.Const.World.LocationType.Unique))
			{
				continue;
			}


			local d = this.m.Home.getTile().getDistanceTo(b.getTile());

			if (d <= 25 && d < lowestDistance)
			{
				lowestDistance = d;
				found = true;
			}
		}
		

		if (!found)
		{
			return;
		}

		this.m.Score = 1;
	}

	function onClear()
	{
	}

	function onExecute( _faction )
	{
		local contract = this.new("scripts/contracts/contracts/nem_barbarian_king_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(this.m.Home);
		contract.setEmployerID(this.m.Home.getChieftain());
		this.World.Contracts.addContract(contract);
	}

});

