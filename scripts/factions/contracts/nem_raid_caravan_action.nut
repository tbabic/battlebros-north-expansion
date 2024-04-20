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
	
	function onExecute( _faction )
	{
		

		this.logInfo("adding caravan contract: " + this.m.Home.getName());
		local contract = this.new("scripts/contracts/contracts/nem_raid_caravan_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(this.m.Home); //TODO: check this
		contract.setEmployerID(this.m.Home.getChieftain().getID());
		//contract.setCaravanInfo(this.m.EnemyFaction, this.m.StartId, this.m.DestId);
		this.World.Contracts.addContract(contract);
	}

});

