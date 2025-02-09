this.nem_defend_settlement_greenskins_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		Home = null
	},
	function create()
	{
		this.m.ID = "nem_defend_settlements_greenskins_action";
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
		if (!_faction.isReadyForContract())
		{
			return;
		}

		if (this.World.Assets.getBusinessReputation() < 900)
		{
			return;
		}

		if (!this.World.FactionManager.isGreenskinInvasion() && this.Math.rand(1, 100) > 50)
		{
			return;
		}

		local tooFar = true;
		local myTile = this.m.Home.getTile();

		if (tooFar)
		{
			local orcs = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs).getSettlements();

			foreach( b in orcs )
			{
				if (myTile.getDistanceTo(b.getTile()) <= 25)
				{
					tooFar = false;
					break;
				}
			}
		}

		if (tooFar)
		{
			local goblins = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Goblins).getSettlements();

			foreach( b in goblins )
			{
				if (myTile.getDistanceTo(b.getTile()) <= 25)
				{
					tooFar = false;
					break;
				}
			}
		}

		if (tooFar)
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
		local contract = this.new("scripts/contracts/contracts/nem_defend_settlement_greenskins_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(this.m.Home);
		contract.setEmployerID(this.m.Home.getChieftain().getID());
		this.World.Contracts.addContract(contract);
	}

});

