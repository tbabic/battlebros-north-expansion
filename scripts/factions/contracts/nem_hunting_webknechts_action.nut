this.nem_hunting_webknechts_action <- this.inherit("scripts/factions/faction_action", {
	m = {},
	function create()
	{
		this.m.ID = "nem_hunting_webknechts_action";
		this.m.Cooldown = this.World.getTime().SecondsPerDay * 14;
		this.m.IsStartingOnCooldown = false;
		this.m.IsSettlementsRequired = true;
		this.faction_action.create();
	}

	function onUpdate( _faction )
	{
		if (!this.Const.DLC.Unhold)
		{
			return;
		}
		
		if (!_faction.getFlags().get("IsBarbarianFaction"))
		{
			return;
		}

		if (!_faction.isReadyForContract())
		{
			return;
		}
		this.logInfo("check: " + this.m.ID);
		local village = _faction.getSettlements()[0];

		if (!village.isNearbyForest())
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
		local contract = this.new("scripts/contracts/contracts/hunting_webknechts_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(_faction.getSettlements()[0]);
		contract.setEmployerID(_faction.getRandomCharacter().getID());
		this.World.Contracts.addContract(contract);
	}

});

