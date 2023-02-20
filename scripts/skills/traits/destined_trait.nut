this.destined_trait <- this.inherit("scripts/skills/traits/character_trait", {
	m = {},
	function create()
	{
		logInfo("creating destined trait");
		this.character_trait.create();
		this.m.ID = "trait.destined";
		this.m.Name = "Destined";
		this.m.Icon = "ui/traits/trait_icon_destined.png";
		this.m.Description = "You know the time and manner of your death, and it is not here and it is not now.";
		this.m.Type = this.m.Type;
		this.m.Titles = [];
		this.m.Excluded = [];
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
				icon = "ui/icons/melee_defense.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+5[/color] Melee Defense\n[color=" + this.Const.UI.Color.PositiveValue + "]+5[/color] Ranged Defense"
			}
		];
	}

	function onUpdate( _properties )
	{
		_properties.MeleeDefense += 5;
		_properties.RangedDefense += 5;
	}

});

