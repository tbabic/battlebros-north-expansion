this.nem_defend_settlement_barbarians_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		Home = null
	},
	function create()
	{
		this.m.ID = "nem_defend_settlements_bandits_action";
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
		if (!_faction.isReadyForContract())
		{
			return;
		}

		if (_faction.getSettlements()[0].isIsolated())
		{
			return;
		}

		if (this.World.Assets.getBusinessReputation() < 500)
		{
			return;
		}
		
		if (this.Math.rand(1, 100) > 10)
		{
			return;
		}

		local myTile = this.m.Home.getTile();
		
		local nearest = ::NorthMod.Utils.nearestBarbarianNeighbour(this.m.Home);
		if (nearest.settlement == null)
		{
			this.logInfo("no settlement found");
			return;
		}
		if (nearest.distance > 20)
		{
			this.logInfo("camp " + nearest.settlement.getName() + " too far: " + nearest.distance);
			return;
		}
		this.m.Score = 1;
	}

	function onClear()
	{
	}

	function onExecute( _faction )
	{
		local contract = this.new("scripts/contracts/contracts/nem_defend_settlement_bandits_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(this.m.Home);
		contract.setEmployerID(this.m.Home.getChieftain().getID());
		this.World.Contracts.addContract(contract);
	}

});

