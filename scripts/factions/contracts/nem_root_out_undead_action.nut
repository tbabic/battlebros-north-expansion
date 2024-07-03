this.nem_root_out_undead_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		Home = null
	},
	function create()
	{
		this.m.ID = "nem_root_out_undead_action";
		this.m.Cooldown = this.World.getTime().SecondsPerDay * 5;
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

		if (!this.World.FactionManager.isUndeadScourge())
		{
			return;
		}

		if (this.Math.rand(1, 100) > 30)
		{
			return;
		}

		if (!this.World.Ambitions.getAmbition("ambition.make_nobles_aware").isDone())
		{
			return;
		}
		local myTile = this.m.Home.getTile();
		
		local nearest_undead = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Undead).getNearestSettlement(myTile);
		
		if (myTile.getDistanceTo(nearest_undead.getTile()) > 20)
		{
			return;
		}
		local nearest_zombies = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Zombies).getNearestSettlement(myTile);
		if (myTile.getDistanceTo(nearest_zombies.getTile()) > 20)
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
		local contract = this.new("scripts/contracts/contracts/nem_root_out_undead_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(this.m.Home);
		contract.setEmployerID(this.m.Home.getChieftain().getID());
		this.World.Contracts.addContract(contract);
	}

});

