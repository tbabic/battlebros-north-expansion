this.nem_barbarian_king_action <- this.inherit("scripts/factions/faction_action", {
	m = {},
	function create()
	{
		this.m.ID = "barbarian_king_action";
		this.m.Cooldown = this.World.getTime().SecondsPerDay * 7;
		this.m.IsStartingOnCooldown = false;
		this.m.IsSettlementsRequired = true;
		this.faction_action.create();
	}

	function onUpdate( _faction )
	{
		if (!this.Const.DLC.Wildmen || this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians) == null)
		{
			return;
		}

		if (!_faction.isReadyForContract())
		{
			return;
		}

		if (_faction.getPlayerRelation() <= 25)
		{
			return;
		}

		if (this.World.Assets.getBusinessReputation() < 1400)
		{
			return;
		}

		if (this.Math.rand(1, 100) > 10)
		{
			return;
		}

		if (!this.World.Ambitions.getAmbition("ambition.make_nobles_aware").isDone())
		{
			return;
		}

		local settlements = _faction.getSettlements();
		local barbarians = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians).getSettlements();
		local lowestDistance = 9999;
		local lowestDistanceSettlement;

		foreach( s in settlements )
		{
			foreach( b in barbarians )
			{
				if (b.isLocationType(this.Const.World.LocationType.Unique))
				{
					continue;
				}

				local d = s.getTile().getDistanceTo(b.getTile());

				if (d <= 25 && d < lowestDistance)
				{
					lowestDistance = d;
					lowestDistanceSettlement = s;
				}
			}
		}

		if (lowestDistanceSettlement == null)
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
		local contract = this.new("scripts/contracts/contracts/nem_barbarian_king_contract");
		contract.setFaction(_faction.getID());
		contract.setEmployerID(_faction.getRandomCharacter().getID());
		this.World.Contracts.addContract(contract);
	}

});

