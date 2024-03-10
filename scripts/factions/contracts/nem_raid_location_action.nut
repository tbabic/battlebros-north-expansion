this.nem_raid_location_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		Home = null,
		Target = null
	},
	function create()
	{
		this.m.ID = "raze_attached_location_action";
		this.m.Cooldown = this.World.getTime().SecondsPerDay * 14;
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
		local targets = [];
		

		foreach( s in startSettlements )
		{
			if (s.getAttachedLocations().len() == 0 )
			{
				continue;
			}

			foreach( a in s.getAttachedLocations() )
			{
				if (a.isActive() && a.isUsable())
				{
					targets.push(a);
				}
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
	}

	function onExecute( _faction )
	{
		
		local contract = this.new("scripts/contracts/contracts/nem_raid_location_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(this.m.Home);
		contract.setEmployerID(this.m.Home.getChieftain());
		contract.setOrigin(this.m.Home);
		contract.setSettlement(this.m.Home);
		contract.setLocation(this.m.Target);
		this.World.Contracts.addContract(contract);
	}

});

