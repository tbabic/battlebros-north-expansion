this.nem_roaming_beasts_action <- this.inherit("scripts/factions/faction_action", {
	m = {},
	function create()
	{
		this.m.ID = "nem_roaming_beasts_action";
		this.m.Cooldown = this.World.getTime().SecondsPerDay * 9;
		this.m.IsStartingOnCooldown = false;
		this.m.IsSettlementsRequired = true;
		this.faction_action.create();
	}

	function onUpdate( _faction )
	{
		if (!_faction.getFlags().get("IsBarbarianFaction"))
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
	}

	function onExecute( _faction )
	{
		local contract = this.new("scripts/contracts/contracts/nem_roaming_beasts_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(_faction.getSettlements()[0]);
		contract.setEmployerID(_faction.getRandomCharacter().getID());
		this.World.Contracts.addContract(contract);
	}

});

