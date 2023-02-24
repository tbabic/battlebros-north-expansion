this.reach_renown_ambition <- this.inherit("scripts/ambitions/ambition", {
	m = {},
	function create()
	{
		this.ambition.create();
		this.m.ID = "ambition.reach_renown";
		this.m.Duration = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.ButtonText = "We need to become more known in these lands, so that everyone treats us with respect. We shall increase our renown!";
		this.m.RewardTooltip = "You\'ll unlock entirely new contracts and ambitions.";
		this.m.UIText = "Reach \'Reputable\' renown";
		this.m.TooltipText = "Become known as \'Reputable\' (1,400 renown). You can increase your renown by completing contracts and winning battles.";
		this.m.SuccessText = "[img]gfx/ui/events/event_31.png[/img]You pushed your men to great deeds, outstanding bravery, and plentiful bloodshed. After several contracts and more than a few skirmishes, you worked hard enough and long enough so that folks finally know the name %companyname%";
		this.m.SuccessButtonText = "We have earned a name for ourselves!";
	}

	function onUpdateScore()
	{
		if (this.World.Ambitions.getDone() < 2)
		{
			return;
		}

		if (this.World.Assets.getBusinessReputation() < 1000)
		{
			return;
		}
		if (this.World.Assets.getOrigin().getID() != "scenario.barbarian_raiders")
		{
			return;
		}
		if (this.World.Statistics.getFlags().get("NorthExpansionCivilLevel") >= 3) {
			return;
		}

		this.m.Score = 10;
	}

	function onCheckSuccess()
	{
		if (this.World.Assets.getBusinessReputation() >= 1400)
		{
			return true;
		}

		return false;
	}

	function onReward()
	{
		this.m.SuccessList.push({
			id = 10,
			icon = "ui/icons/special.png",
			text = "You will now get better contracts."
		});
		this.World.Ambitions.getAmbition("ambition.make_nobles_aware").setDone(true);
	}

	function onSerialize( _out )
	{
		this.ambition.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		this.ambition.onDeserialize(_in);
	}

});

