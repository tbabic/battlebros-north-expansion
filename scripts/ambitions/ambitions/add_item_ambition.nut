this.add_item_ambition <- this.inherit("scripts/ambitions/ambition", {
	m = {},
	function create()
	{
		this.ambition.create();
		this.m.ID = "ambition.add_item";
		this.m.Duration = 14.0 * this.World.getTime().SecondsPerDay;
		this.m.ButtonText = "Add skald item";
		this.m.RewardTooltip = "You\'ll be awarded a unique item that grants anyone near the wearer additional resolve..";
		this.m.UIText = "Have one man with the \'Rally the Troops\' perk";
		this.m.TooltipText = "Have at least one man with the \'Rally the Troops\' perk. You\'ll also need space enough in your inventory for a new item.";
		this.m.SuccessText = "[img]gfx/ui/events/event_64.png[/img]Whatever";
	}

	function onUpdateScore()
	{
		this.m.Score = 0;
	}

	function onCheckSuccess()
	{
		return true;
	}

	function onReward()
	{
		local item = this.new("scripts/items/accessory/skaldhorn");
		this.World.Assets.getStash().add(item);
	}

	function onPrepareVariables( _vars )
	{
		local brothers = this.World.getPlayerRoster().getAll();
		local highestBravery = 0;
		local bestSergeant;

		foreach( bro in brothers )
		{
			if (bro.getCurrentProperties().getBravery() > highestBravery)
			{
				bestSergeant = bro;
				highestBravery = bro.getCurrentProperties().getBravery();
			}
		}

		_vars.push([
			"sergeantbrother",
			bestSergeant.getNameOnly()
		]);
		_vars.push([
			"sergeantbrotherfull",
			bestSergeant.getName()
		]);
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

