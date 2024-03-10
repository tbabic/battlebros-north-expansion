this.nem_hunting_schrats_action <- this.inherit("scripts/factions/faction_action", {
	m = {
		Home = null
	},
	function create()
	{
		this.m.ID = "nem_hunting_schrats_action";
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
		
		if (_faction.getType() != this.Const.FactionType.Barbarians)
		{
			return;
		}

		if (!_faction.isReadyForContract())
		{
			return;
		}

		if (this.World.Assets.getBusinessReputation() < 1500)
		{
			return;
		}


		if (!::NorthMod.Utils.isNearbyForest(this.m.Home))
		{
			return;
		}

		local mapSize = this.World.getMapSize();
		local villageTile = this.m.Home.getTile();
		local x = this.Math.max(3, villageTile.SquareCoords.X - 11);
		local x_max = this.Math.min(mapSize.X - 3, villageTile.SquareCoords.X + 11);
		local y = this.Math.max(3, villageTile.SquareCoords.Y - 11);
		local y_max = this.Math.min(mapSize.Y - 3, villageTile.SquareCoords.Y + 11);
		local numWoods = 0;

		while (x <= x_max)
		{
			while (y <= y_max)
			{
				local tile = this.World.getTileSquare(x, y);

				if (tile.Type == this.Const.World.TerrainType.Forest || tile.Type == this.Const.World.TerrainType.LeaveForest || tile.Type == this.Const.World.TerrainType.AutumnForest)
				{
					numWoods = ++numWoods;
				}

				y = ++y;
			}

			x = ++x;
		}

		if (numWoods == 0)
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
		local contract = this.new("scripts/contracts/contracts/nem_hunting_schrats_contract");
		contract.setFaction(_faction.getID());
		contract.setHome(this.m.Home);
		contract.setEmployerID(this.m.Home.getChieftain());
		this.World.Contracts.addContract(contract);
	}

});

