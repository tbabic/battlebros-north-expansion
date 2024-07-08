this.nem_decisive_battle_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		Home = null
	},
	function create()
	{
		this.m.ID = "action.nem_decisive_battle";
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

		if (this.World.Assets.getBusinessReputation() < 1600)
		{
			return;
		}

		if (!this.World.FactionManager.isCivilWar() && !this.World.FactionManager.isHolyWar())
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

		this.m.Score = 1;
	}

	function onClear()
	{
	}

	function onExecute( _faction )
	{
		local contract = this.new("scripts/contracts/contracts/nem_decisive_battle_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(this.m.Home);
		contract.setEmployerID(this.m.Home.getChieftain().getID());
		this.World.Contracts.addContract(contract);
	}

});

