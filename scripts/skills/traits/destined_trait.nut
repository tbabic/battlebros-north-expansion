this.destined_trait <- this.inherit("scripts/skills/traits/character_trait", {
	m = {},
	function create()
	{
		this.character_trait.create();
		this.m.ID = "trait.destined";
		this.m.Name = "Destined";
		this.m.Icon = "ui/traits/trait_icon_destined.png";
		this.m.Description = "This character knows the time and manner of his death, and it is not here and it is not now.";
		this.m.Type = this.m.Type;
		this.m.Titles = [];
		this.m.Excluded = [];
		
		foreach (t in this.Const.CharacterTraits)
		{
			this.m.Excluded.push(t[0]);
		}
		this.m.Excluded.push("trait.champion");
	}

	function getTooltip()
	{
		return [
			{
				id = 1,
				type = "title",
				text = this.getName()
			},
			{
				id = 2,
				type = "description",
				text = this.getDescription()
			},
			{
				id = 10,
				type = "text",
				icon = "ui/icons/morale.png",
				text = "Will start combat at confident morale if permitted by mood"
			},
			{
				id = 11,
				type = "text",
				icon = "ui/icons/bravery.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+5[/color] Resolve"
			},
			{
				id = 12,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Re-roll every failed morale check for a second chance"
			}
		];
	}

	function onUpdate( _properties )
	{
		_properties.RerollMoraleChance = 100;
		_properties.Bravery += 5;
	}
	
	function onCombatStarted()
	{
		local actor = this.getContainer().getActor();

		if (actor.getMoodState() >= this.Const.MoodState.Neutral && actor.getMoraleState() < this.Const.MoraleState.Confident)
		{
			actor.setMoraleState(this.Const.MoraleState.Confident);
		}
	}

});

