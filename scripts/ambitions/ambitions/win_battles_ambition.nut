this.win_battles_ambition <- this.inherit("scripts/ambitions/ambition", {
	m = {
		Defeated = 0
	},
	function create()
	{
		this.ambition.create();
		this.m.ID = "ambition.win_battles";
		this.m.Duration = 7.0 * this.World.getTime().SecondsPerDay;
		this.m.ButtonText = "We need to win some battles to increase our reputation.";
		this.m.UIText = "Win two battles against any enemies";
		this.m.TooltipText = "Win two battles against any enemies, whether by killing them or having them scatter and flee. You can do so as part of a contract or by fighting on your own terms.";
		this.m.SuccessText = "[img]gfx/ui/events/event_22.png[/img]As all your enemies either lie dead or are in retreat, %bravest_brother% waves the company\'s banner in celebration.%SPEECH_ON%Once more the %companyname% fought, and once more the %companyname% prevailed!%SPEECH_OFF%Raucous cheers echo him all around. You soon discover that your recent battle is the talk of the local towns and villages. Whenever they stop at a tavern along the road, the brothers find that drinks are poured when the story of that battle is told, and the more the telling is embellished, the more freely the libations flow.";
		this.m.SuccessButtonText = "We tested ourselves, but greater things await.";
	}

	function onUpdateScore()
	{
		this.m.Score = 1 + this.Math.rand(0, 5);
	}

	function onCheckSuccess()
	{
		if (this.m.Defeated >= 2)
		{
			return true;
		}

		return false;
	}

	function onLocationDestroyed( _location )
	{
		this.m.Defeated++;
	}

	function onPartyDestroyed( _party )
	{
		this.m.Defeated++;
	}

	function onReward()
	{
		this.m.SuccessList.push({
			id = 10,
			icon = "ui/icons/special.png",
			text = "You gain additional renown for your victory"
		});
	}

	function onSerialize( _out )
	{
		this.ambition.onSerialize(_out);
		_out.writeU16(this.m.Defeated);
	}

	function onDeserialize( _in )
	{
		this.ambition.onDeserialize(_in);
		this.m.Defeated = _in.readU16();
	}

});

