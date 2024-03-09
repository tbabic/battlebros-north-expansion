this.nem_hunting_webknechts_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		Home = null
	},
	function create()
	{
		this.m.ID = "nem_hunting_webknechts_action";
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
		
		if (this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians) != _faction)
		{
			return;
		}

		if (!_faction.isReadyForContract())
		{
			return;
		}
		this.logInfo("check: " + this.m.ID);

		if (!::NorthMod.Utils.isNearbyForest(this.m.Home))
		{
			this.logInfo("no forest");
			return;
		}

		this.m.Score = 1;
	}

	function onClear()
	{
	}

	function onExecute( _faction )
	{
		local contract = this.new("scripts/contracts/contracts/nem_hunting_webknechts_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(this.m.Home);
		contract.setEmployerID(this.m.Home.getChieftain());
		this.World.Contracts.addContract(contract);
	}

});

