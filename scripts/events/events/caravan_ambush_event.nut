this.caravan_ambush_event <- this.inherit("scripts/events/event", {
	m = {
		Faction = null,
		multiplier = 3
	},
	//TODO: test this event
	function create()
	{
		this.m.ID = "event.caravan_ambush";
		this.m.Title = "Along the road...";
		this.m.Cooldown = this.m.multiplier * this.World.getTime().SecondsPerDay;
		this.m.Faction = null;
		
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_55.png[/img]While marching down the road, you find a %caravan% with a broken cart by the side of the path. Caravan hands are busy trying to get the wheels back on, unsuspecting of your men approaching.%SPEECH_ON% Easy pickings, chief.%SPEECH_OFF%%randombrother% mutters in your ear.%SPEECH_ON%Let's ease their trouble and take what we can.%SPEECH_OFF%"
			
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "No, we need friends. We'll help them out.",
					function getResult( _event )
					{
						return "B";
					}

				},
				{
					Text = "It's not the time to make enemies. Let's just move on.",
					function getResult( _event )
					{
						return "C";
					}

				},
				{
					Text = "Yes, we need those supplies. Kill them all.",
					function getResult( _event )
					{
						return "D";
					}

				}
			],
			function start( _event )
			{
				
			}

		});
		
		this.m.Screens.push({
			ID = "B",
			Text = "Thanks for helping out"
			Image = "",
			List = [],
			Characters = [],
			Banner = "",
			Options = [
				{
					Text = "Spread the word.", //TODO: text;
					function getResult( _event )
					{
						this.m.Faction.addPlayerRelation(this.Const.World.Assets.RelationNobleContractSuccess, "Helped out their caravan");
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = this.m.Faction.getUIBannerSmall();
			}

		});
		
		this.m.Screens.push({
			ID = "C",
			Text = "Just passing by"
			Image = "",
			List = [],
			Characters = [],
			Banner = "",
			Options = [
				{
					Text = "We'll be on our way.", //TODO: text;
					function getResult( _event )
					{
						this.m.Faction.addPlayerRelation(this.Const.World.Assets.RelationNobleContractPoor, "Avoided attacking a caravan");
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = this.m.Faction.getUIBannerSmall();
			}

		});
		
		this.m.Screens.push({
			ID = "D",
			Text = "They are all dead"  //TODO: text;
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "This is good loot!",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				//TODO: add loot
			}

		});
		
		

	}

	function onUpdateScore()
	{
		this.logInfo("update score: caravan ambush");
		if (!this.Const.DLC.Wildmen)
		{
			return;
		}
		
		if (!this.World.Flags.get("NorthExpansionActive") )
		{
			return;
		}
		
		if (!this.World.Ambitions.hasActiveAmbition() || this.World.Ambitions.getActiveAmbition().getID() != "ambition.make_civil_friends")
		{
			this.logInfo("caravan ambush: no ambition");
			return;
		}
		local currentTile = this.World.State.getPlayer().getTile();
		if (!currentTile.HasRoad)
		{
			return;
		}
		
		//TODO: score;
		
		this.m.Score = 0;
	}

	function onPrepare()
	{
		local currentTile = this.World.State.getPlayer().getTile();
		local nobles = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);
		local houses = [];

		foreach( n in nobles )
		{
			local closest;
			local dist = 9999;

			foreach( s in n.getSettlements() )
			{
				local d = s.getTile().getDistanceTo(currentTile);

				if (d < dist)
				{
					dist = d;
					closest = s;
				}
			}

			houses.push({
				Faction = n,
				Dist = dist
			});
		}
		
		houses.sort(function ( _a, _b )
		{
			if (_a.Dist > _b.Dist)
			{
				return 1;
			}
			else if (_a.Dist < _b.Dist)
			{
				return -1;
			}

			return 0;
		});
		
		local r = Math.rand(1,7);
		if (r <= 4) {
			this.m.Faction = houses[0];
		}
		else if (r <= 6) {
			this.m.Faction = houses[1];
		}
		else {
			this.m.Faction = houses[2];
		}
		
		
	}

	function onPrepareVariables( _vars )
	{
		
		_vars.push([
			"caravan",
			this.m.Faction.getName() + " caravan"
		]);
	}

	function onClear()
	{
		this.m.Faction = null;
	}

});

