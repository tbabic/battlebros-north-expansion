this.nem_raid_location_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		Home = null,
		Settlement = null,
		Target = null
	},
	function create()
	{
		this.m.ID = "nem_raid_location_action";
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
		this.m.Target = null;
		this.m.Settlement = null;
		if (_faction.getType() != this.Const.FactionType.Barbarians)
		{
			return;
		}
		if (!_faction.isReadyForContract())
		{
			return;
		}
		this.logInfo("check: " + this.m.ID);

		local hasActiveLocation = false;
		
		local startSettlements = [];
		foreach(f in this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse))
		{
			startSettlements.extend(f.getSettlements());
		}
		
		local targetSettlements = [];
		local myTile = this.m.Home.getTile();

		foreach( s in startSettlements )
		{
			if (s.getAttachedLocations().len() == 0 || s.isMilitary())
			{
				continue;
			}
			if (myTile.getDistanceTo(s.getTile()) > 50 || s.getTile().Coords.Y < (this.World.getMapSize().Y * 0.5))
			{
				continue;
			}
			targetSettlements.push(s);
		}
		if(targetSettlements.len() <= 0)
		{
			return;
		}
		
		this.m.Settlement = targetSettlements[this.Math.rand(0, targetSettlements.len()-1)];
		
		
		local targets = [];
		foreach( a in this.m.Settlement.getAttachedLocations() )
		{
			if (a.isActive() && a.isUsable())
			{
				targets.push(a);
			}
		}

		if(targets.len() <= 0)
		{
			return;
		}
		this.m.Target = targets[this.Math.rand(0, targets.len()-1)];
		this.m.Score = 1;
	}

	function onClear()
	{
		this.m.Target = null;
		this.m.Settlement = null;
	}

	function onExecute( _faction )
	{
		this.logInfo("execute contract:" + this.m.ID + " for " + this.m.Home.getID());
		local contract = this.new("scripts/contracts/contracts/nem_raid_location_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(this.m.Home);
		contract.setEmployerID(this.m.Home.getChieftain().getID());
		contract.setOrigin(this.m.Home);
		contract.setSettlement(this.m.Settlement);
		contract.setTarget(this.m.Target);
		this.World.Contracts.addContract(contract);
	}

});

