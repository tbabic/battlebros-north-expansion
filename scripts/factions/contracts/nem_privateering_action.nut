this.nem_privateering_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		Home = null
	},
	function create()
	{
		this.m.ID = "action.nem_privateering";
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

		local nobleHouses = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);
		local hasTarget = false;

		foreach( h in nobleHouses )
		{
			if (h.getID() == _faction.getID())
			{
				continue;
			}

			local c = 0;

			foreach( s in h.getSettlements() )
			{
				if (s.isIsolated() || !s.isDiscovered() || s.getActiveAttachedLocations().len() == 0)
				{
					continue;
				}

				c = ++c;
			}

			if (c >= 3)
			{
				hasTarget = true;
				break;
			}
		}

		if (!hasTarget)
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
		local contract = this.new("scripts/contracts/contracts/nem_privateering_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(this.m.Home);
		contract.setEmployerID(this.m.Home.getChieftain().getID());
		this.World.Contracts.addContract(contract);
	}

});

