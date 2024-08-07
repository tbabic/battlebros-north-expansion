this.barbarian_recruits_event <- this.inherit("scripts/events/event", {
	m = {
		Dude = null,
		Town = null
	},
	
	function create()
	{
		this.m.ID = "event.barbarian_recruits";
		this.m.Title = "At %townname%";
		this.m.Cooldown = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_20.png[/img]A man moves through the crowd shoving everybody in his path. He is heading straight for you, but two of your men stop to block his approach. The man gestures to mean no harm and you nod your men to let him through. He speaks softly and quietly, unusual for such a large man.%SPEECH_ON%I\'ve heard you are looking for men. You\'ve got a reputation as a capable group, and I\'d like to join.%SPEECH_OFF%You ask him, why you should let him in your warband, when %randombrother% interjects.%SPEECH_ON%That\'s, %recruit%, I\'ve heard of him. He is a good fighter, or so I\'ve been told.%SPEECH_OFF%Your man pauses for a moment and then adds. %SPEECH_ON%Haven\'t seen him myself, though. People tell a lot of things, so might be I\'ve been told wrong.%SPEECH_OFF%",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "We need new men.",
					function getResult( _event )
					{
						this.World.getPlayerRoster().add(_event.m.Dude);
						this.World.getTemporaryRoster().clear();
						_event.m.Dude.onHired();
						_event.m.Dude = null;
						return 0;
					}

				},
				{
					Text = "Not today.",
					function getResult( _event )
					{
						this.World.getTemporaryRoster().clear();
						_event.m.Dude = null;
						return 0;
					}

				}
			],
			function start( _event )
			{
				local roster = this.World.getTemporaryRoster();
				_event.m.Dude = roster.create("scripts/entity/tactical/player");
				_event.m.Dude.setStartValuesEx([
					"barbarian_background"
				]);
				_event.m.Dude.getBackground().buildDescription(true);
				_event.m.Dude.getItems().equip(this.new("scripts/items/accessory/warhound_item"));
				this.Characters.push(_event.m.Dude.getImagePath());
			}

		});
	}

	function onUpdateScore()
	{
		logInfo("update score: " + this.m.ID);
		if (!this.Const.DLC.Wildmen)
		{
			return;
		}

		local currentTile = this.World.State.getPlayer().getTile();
		
		local multiplier = 1;
		if (!this.Const.DLC.Wildmen)
		{
			return;
		}
		
		if (!this.World.Flags.get("NorthExpansionActive") )
		{
			return;
		}
		if (this.World.getPlayerRoster().getSize() >= this.World.Assets.getBrothersMax())
		{
			return;
		}
		local faction = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians);
		local settlements = faction.getSettlements();
		local inBarbarianVillage = false;
		local town;
		local playerTile = this.World.State.getPlayer().getTile();
		logInfo("findTown");
		foreach( s in settlements )
		{
			
			if(s.isLocationType(this.Const.World.LocationType.Unique))
			{
				continue;
			}
			
			if (s.getTile().getDistanceTo(playerTile) <=4 )
			{
				town = s;
				inBarbarianVillage = true;
			}
		}
		if(!inBarbarianVillage)
		{
			logInfo("town not found");
			return
		}
		
		if (this.World.Ambitions.hasActiveAmbition() && this.World.Ambitions.getActiveAmbition().getID() == "ambition.roster_of_12")
		{
			multiplier = 2;
		}
		
		if(this.World.Flags.get("NorthExpansionCivilLevel") == 1) {
			multiplier = multiplier * 5;
		}
		
		this.m.Town = town;
		this.m.Score = 1 * multiplier;
		logInfo("updated score: " + this.m.ID + " - " + this.m.Score);
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
	
		_vars.push([
			"townname",
			this.m.Town.getName()
		]);
		_vars.push([
			"recruit",
			this.m.Dude.getName()
		]);
	}

	function onClear()
	{
		this.m.Dude = null;
		this.m.Town = null;
	}

});

