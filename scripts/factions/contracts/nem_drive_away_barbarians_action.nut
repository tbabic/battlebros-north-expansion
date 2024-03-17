this.nem_drive_away_barbarians_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		Home = null
	},
	function create()
	{
		this.m.ID = "nem_drive_away_barbarians_action";
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
		if (!this.Const.DLC.Wildmen || this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians) == null)
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

		local tooFar = true;
		local nearest = ::NorthMod.Utils.nearestBarbarianNeighbour(this.m.Home);
		if (nearest.settlement == null)
		{
			this.logInfo("no settlement found");
			return;
		}
		if (nearest.distance > 12)
		{
			this.logInfo("camp " + nearest.settlement.getName() + " too far: " + nearest.distance);
			return;
		}

		this.m.Score = 1;
	}

	function onClear()
	{
	}

	function onExecute( _faction )
	{
		local contract = this.new("scripts/contracts/contracts/nem_drive_away_barbarians_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(this.m.Home);
		contract.setEmployerID(this.m.Home.getChieftain().getID());
		this.World.Contracts.addContract(contract);
	}

});

