this.throwing_mastery_ambition <- this.inherit("scripts/ambitions/ambition", {
	m = {},
	function create()
	{
		this.ambition.create();
		this.m.ID = "ambition.throwing_mastery";
		this.m.Duration = 21.0 * this.World.getTime().SecondsPerDay;
		this.m.ButtonText = "The warband lacks competent throwers, limiting our charge.\nWe shall train four men to master throwing and support our charge!";
		this.m.UIText = "Have men with the throwing mastery perk";
		this.m.TooltipText = "Have 4 men with the throwing mastery perk.";
		this.m.SuccessText = "[img]gfx/ui/events/event_10.png[/img]At every opportunity, you encourage the men under your command to let loose a few volleys. Everyone participates, even the slow witted louts who would sleep in their armor if you let them. Any target at all suffices: the bole of a small tree, a doe grazing in the early hours, or a goblin scout fleeing for his life.%SPEECH_ON%Yes, we are the terror of hay bales throughout the land!%SPEECH_OFF%%randombrother% says, referring to a common choice of target during practice. He ducks when a javelin from one of his comrades whistles close past his skull and starts cursing at the shooter.\n\nWith plenty of practice, those javelins are striking closer and closer to the bullseye, and now that the company is fielding better trained throwers, your frontline is breathing easier and living, at least marginally, longer.";
		this.m.SuccessButtonText = "This will serve us well.";
	}

	function getUIText()
	{
		return this.m.UIText + " (" + this.Math.min(3, this.getBrosWithMastery()) + "/3)";
	}

	function getBrosWithMastery()
	{
		local brothers = this.World.getPlayerRoster().getAll();
		local count = 0;

		foreach( bro in brothers )
		{
			local p = bro.getCurrentProperties();

			if (p.IsSpecializedInThrowing)
			{
				count = ++count;
			}
		}

		return count;
	}

	function onUpdateScore()
	{
		if (this.World.Assets.getOrigin().getID() != "scenario.barbarian_raiders")
		{
			return;
		}
		if (this.World.Statistics.getFlags().get("NorthExpansionCivilLevel") >= 3) {
			return;
		}
		
		if (this.World.getTime().Days <= 25)
		{
			return;
		}

		if (this.World.Ambitions.getDone() < 2)
		{
			return;
		}

		local count = this.getBrosWithMastery();

		if (count >= 4)
		{
			return;
		}

		this.m.Score = 1 + this.Math.rand(0, 5);
	}

	function onCheckSuccess()
	{
		local count = this.getBrosWithMastery();

		if (count >= 4)
		{
			return true;
		}

		return false;
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

