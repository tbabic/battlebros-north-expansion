this.barbarian_raiders_intro_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.barbarian_raiders_scenario_intro";
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_87.png[/img]{There is always a chance that a raid goes wrong, but this one has gone quite unexpectedly. Some monk has started blabbering about south and becoming mercenaries, bunch of unholds turd, but he\'s actually managed to convince %southerner% and others. Most of the crew take their share of the loot and went south. They took the monk as well. Some good at least, such a weakling would never make a good warrior. You\'ve heard of south. A hot place, where only sand is beneath your feet and no sight of snow. A place where, instead of direwolves, there are packs of snakes roaming, where instead of giants, rocks walk the lands. Where instead of weapons, men carry boomsticks. You\'ve heard of the south and decided against it.\n\nYou look at the men that stayed with you, %friend%, your most loyal friend and %other%. Not much, but better than nothing. Now you just need to put them to work. Find some caravan or village to plunder. As if he noticed your thoughts, %friend% comes with a suggestion.%SPEECH_ON%Chief, I\'ve heard %chieftain% is looking for men. Heard he might have some job that needs doing. Who knows, we might find some men for our crew there. What do you think?%SPEECH_OFF%}",
			Image = "",
			Banner = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Let\'s find some work!",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Banner = "ui/banners/" + this.World.Assets.getBanner() + "s.png";
			}

		});
	}

	function onUpdateScore()
	{
		return;
	}

	function onPrepare()
	{
		this.m.Title = "Barbarian Destiny";
	}

	function onPrepareVariables( _vars )
	{
		local brothers = this.World.getPlayerRoster().getAll();
		_vars.push([
			"raider",
			brothers[0].getName()
		]);
		_vars.push([
			"friend",
			brothers[1].getName()
		]);
		_vars.push([
			"other",
			brothers[2].getName()
		]);

		_vars.push([
			"southerner",
			this.Const.Strings.BarbarianNames[this.Math.rand(0, this.Const.Strings.BarbarianNames.len() - 1)]
		]);
		
		local factions = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.Settlement);
		local f = null;
		foreach (faction in factions)
		{
			if (faction.getFlags().get("IsBarbarianFaction") == true)
			{	
				f = faction;
				break;
			}
		}
		
		logInfo("faction:" + f.getName());
		local roster = f.getRoster().getAll();
		logInfo("roster: " + roster.len());
		
		
		local chieftain = f.getRandomCharacter()
		_vars.push([
			"chieftain",
			chieftain.getName()
		]);
		
	}

	function onClear()
	{
	}

});

