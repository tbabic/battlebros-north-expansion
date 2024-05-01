this.nem_defend_settlement_nobles_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		Home = null
	},
	function create()
	{
		this.m.ID = "nem_defend_settlements_nobles_action";
		this.m.Cooldown = this.World.getTime().SecondsPerDay * 28;
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

		if (this.World.Assets.getBusinessReputation() < 1500)
		{
			return;
		}

		if (this.Math.rand(1, 100) > 10)
		{
			return;
		}

	
		local tooFar = true;
		local myTile = this.m.Home.getTile();
		
		local nearestSettlement = this.getNearestLocationTo(this.m.Home, this.World.EntityManager.getSettlements())
		if (myTile.getDistanceTo(nearestSettlement.getTile()) <= 20)
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
		local contract = this.new("scripts/contracts/contracts/nem_defend_settlement_nobles_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(this.m.Home);
		contract.setEmployerID(this.m.Home.getChieftain().getID());
		this.World.Contracts.addContract(contract);
	}

});

