this.nem_hunting_unholds_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		EnemyType = 0,
		Home = null
	},
	function create()
	{
		this.m.ID = "nem_hunting_unholds_action";
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

		if (this.World.Assets.getBusinessReputation() < 700)
		{
			return;
		}
		this.logInfo("check: " + this.m.ID);
		
		if (::NorthMod.Utils.isNearbySnow(this.m.Home))
		{
			this.m.EnemyType = 1;
		}
		else if (::NorthMod.Utils.isNearbyForest(this.m.Home))
		{
			this.m.EnemyType = 0;
		}
		else
		{
			this.m.EnemyType = 2;
		}
		this.m.Score = 1;
	}

	function onClear()
	{
		this.m.EnemyType = 0;
	}

	function onExecute( _faction )
	{
		local contract = this.new("scripts/contracts/contracts/nem_hunting_unholds_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(this.m.Home);
		contract.setEmployerID(this.m.Home.getChieftain());
		contract.setEnemyType(this.m.EnemyType);
		this.World.Contracts.addContract(contract);
	}

});

