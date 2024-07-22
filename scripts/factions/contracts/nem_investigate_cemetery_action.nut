this.nem_investigate_cemetery_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		Home = null,
		Target = null
	},
	function create()
	{
		this.m.ID = "nem_investigate_cemetery_action";
		this.m.Cooldown = this.World.getTime().SecondsPerDay * 9;
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

		if (!this.World.FactionManager.isUndeadScourge() && this.World.getTime().Days > 3 && this.Math.rand(1, 100) > 75)
		{
			return;
		}

		local myTile = this.m.Home.getTile();
		this.m.Target = null;
		local undead = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Zombies).getSettlements();

		foreach( b in undead )
		{
			if (myTile.getDistanceTo(b.getTile()) < 15 && (b.getTypeID() == "location.undead_graveyard" || b.getTypeID() == "location.undead_crypt"))
			{
				this.m.Target = b;
				break;
			}
		}

		if (this.m.Target == null)
		{
			return;
		}

		this.m.Score = 1;
	}

	function onClear()
	{
		this.m.Target = null;
	}

	function onExecute( _faction )
	{
		local contract = this.new("scripts/contracts/contracts/nem_investigate_cemetery_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(this.m.Home);
		contract.setEmployerID(this.m.Home.getChieftain().getID());
		contract.setDestination(this.m.Target);
		this.World.Contracts.addContract(contract);
	}

});

