this.make_civil_friends_ambition <- this.inherit("scripts/ambitions/ambition", {
	m = {},
	function create()
	{
		this.ambition.create();
		this.m.ID = "ambition.make_civil_friends";
		this.m.Duration = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.ButtonText = "We need to make relations with of one of the noble houses. They'll have more work for us and more resources";
		this.m.RewardTooltip = "You'll be able to trade and work for civilized factions";
		this.m.UIText = "Reach \'Cold\' relations with one of the factions";
		this.m.TooltipText = "Improve your relations to \'Cold\' with one of the major faction. Relations trend towards neutral with time.";
		this.m.SuccessText = "[img]gfx/ui/events/event_31.png[/img]You avoided raiding and pillaging, much to the dismay of your men. You\'ve helped farmers and villagers to their even greater dismay. When you've helped a pompous noble, there was talk of revolt in the %companyname%, but finally your efforts have borne fruit and some civilized settlements are willing to open doors to you.";
		this.m.SuccessButtonText = "We need friends and allies.";
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
		if (!this.World.Flags.get("NorthExpansionActive"))
		{
			return;
		}
		if (this.World.Flags.get("NorthExpansionCivilLevel") >= 3) {
			return;
		}

		this.m.Score = 10;
	}

	function onCheckSuccess()
	{
		local nobles = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);
		foreach (nobleHouse in nobles)
		{
			if (nobles.getPlayerRelations >= 30)
			{
				return true;
			}
		}
		return false;
	}

	function onReward()
	{
		this.m.SuccessList.push({
			id = 10,
			icon = "ui/icons/special.png",
			text = "You can now enter civilized settlements."
		});
		this.World.Ambitions.getAmbition("ambition.make_nobles_aware").setDone(true);
		this.World.Flags.set("NorthExpansionCivilLevel", 2);
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

