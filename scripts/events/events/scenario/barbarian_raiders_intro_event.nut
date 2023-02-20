this.barbarian_raiders_intro_event <- this.inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.barbarian_raiders_scenario_intro";
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_87.png[/img]{It's been a week since you and your friend %friend% joined %chief%'s raiding party and it's been slim pickings, but it looks like you finally struck gold and found a rich caravan. After a brief battle, most of the guards were dead and the rest fled, leaving only a single man in robes, a monk by the looks of it. There was a familiar throbbing in your head, destiny once again playing a trick on you. This man is important to you, at least for now. You raise your voice to stop other raiders from killing him, but they don't look happy. After some arguing and threatening with no progress, you finally ready your sword.%SPEECH_ON%I am Vindurask, from the Frostpeak mountains. Some call me the Whirlwind, some call me the Equalizer and others, they just call me crazy bastard. Great witch Sigrid has shown me my death and it is not here and it is not now. Monk is going with me and if anybody stays in my way, I\'ll cut him in half!%SPEECH_OFF%A moment of silence turns into a minute of hard stares and slow breathing, %friend% stands beside you, his hands gripping an axe. Finally, chief tells you to take the monk and go, but you will no longer be welcome in his tribe. You didn\'t particularly like %chief%, anyway.\n\nAs you walk away monk thanks you for saving him and introduces himself as %monk%.You reply that it\'s not you who saved him, but rather destiny, however you will accept his gratitude and service. Monk calmly shrugs his shoulders as if accepting his fate. But as you walk, he starts suggesting a nearby village might have some work for strong men, a work that pays well. You just nod.}",
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
			"monk",
			brothers[2].getName()
		]);

		_vars.push([
			"chief",
			this.Const.Strings.BarbarianNames[this.Math.rand(0, this.Const.Strings.BarbarianNames.len() - 1)]
		]);
		
	}

	function onClear()
	{
	}

});

