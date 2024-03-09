this.nem_confront_warlord_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		Home = null
	},
	function create()
	{
		this.m.ID = "nem_confront_warlord_action";
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

		if (_faction.getPlayerRelation() <= 25)
		{
			return;
		}

		if (this.World.Assets.getBusinessReputation() < 1500)
		{
			return;
		}

		if (!this.World.FactionManager.isGreenskinInvasion())
		{
			return;
		}

		if (this.Math.rand(1, 100) > 30)
		{
			return;
		}

		local orcs = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).getSettlements();
		local goblins = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).getSettlements();
		local isEnemyNear = false;
		local s = this.m.Home;
		
		foreach( b in orcs )
		{
			local d = s.getTile().getDistanceTo(b.getTile());

			if (d <= 30)
			{
				isEnemyNear = true;
				break;
			}
		}


		foreach( b in goblins )
		{
			local d = s.getTile().getDistanceTo(b.getTile());

			if (d <= 30)
			{
				isEnemyNear = true;
				break;
			}
		}
		

		if (!isEnemyNear)
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
		local contract = this.new("scripts/contracts/contracts/nem_confront_warlord_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(this.m.Home);
		contract.setEmployerID(this.m.Home.getChieftain());
		this.World.Contracts.addContract(contract);
	}

});

