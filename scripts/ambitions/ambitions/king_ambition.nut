this.king_ambition <- this.inherit("scripts/ambitions/ambition", {
	m = {},
	function create()
	{
		this.ambition.create();
		this.m.ID = "ambition.king";
		this.m.Duration = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.ButtonText = "The north needs a king.";
		this.m.RewardTooltip = "You'll become a King of the North";
		this.m.UIText = "Become a King of the North";
		this.m.TooltipText = "Defeat opposing barbarians and improve your reputation.";
		this.m.SuccessText = "[img]gfx/ui/events/event_31.png[/img]The north needs a kind. The north has a king. You've won battles against other barbarians, the clans and settlements have sworn fealty to you. There is no one left to oppose you and if the you, they will be crushed.";
		this.m.SuccessButtonText = "Long live the king!.";
	}

	function onUpdateScore()
	{
		if (this.World.Ambitions.getDone() < 2)
		{
			return;
		}

		if (this.World.Assets.getBusinessReputation() < 2500)
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
		//TODO: check conditions
		//defeat 4 camps and 8 armies, find Heroes location
		if (this.World.Assets.getBusinessReputation() >= 3000)
		{
			return true;
		}
		
		return false;
	}

	function onReward()
	{
		//TODO: king reward armor, noble factions relations
		this.m.SuccessList.push({
			id = 10,
			icon = "ui/icons/special.png",
			text = "You will now get better contracts."
		});
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

