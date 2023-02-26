this.champion_trait <- this.inherit("scripts/skills/traits/character_trait", {
	m = {},
	function create()
	{
		logInfo("creating champion trait");
		this.character_trait.create();
		this.m.ID = "trait.champion";
		this.m.Name = "Champion";
		this.m.Icon = "ui/traits/trait_icon_champion.png";
		this.m.Description = "This character is a champion for his clan and has won every duel.";
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
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+5[/color] Melee Defense\n[color=" + this.Const.UI.Color.PositiveValue + "]+5[/color] Melee Skill"
			},
			{
				id = 11,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Win every duel."
			}
		];
	}

	function onUpdate( _properties )
	{
		_properties.MeleeSkill += 5;
		_properties.RangedDefense += 5;
	}

});

