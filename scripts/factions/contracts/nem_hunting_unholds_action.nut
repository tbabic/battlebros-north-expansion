this.nem_hunting_unholds_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		EnemyType = 0
	},
	function create()
	{
		this.m.ID = "nem_hunting_unholds_action";
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

		if (!_faction.isReadyForContract())
		{
			return;
		}

		if (this.World.Assets.getBusinessReputation() < 700)
		{
			return;
		}

		local village = _faction.getSettlements()[0];
		
		if (village.isNearbySnow())
		{
			this.m.EnemyType = 1;
		}
		else if (village.isNearbyForest())
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
		local contract = this.new("scripts/contracts/contracts/hunting_unholds_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(_faction.getSettlements()[0]);
		contract.setEmployerID(_faction.getRandomCharacter().getID());
		contract.setEnemyType(this.m.EnemyType);
		this.World.Contracts.addContract(contract);
	}

});

