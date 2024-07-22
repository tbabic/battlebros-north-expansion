this.moonkissed_trait <- this.inherit("scripts/skills/traits/character_trait", {
	m = {},
	function create()
	{
		this.character_trait.create();
		this.m.ID = "trait.moonkissed";
		this.m.Name = "Beloved of the Moon";
		this.m.Description = "This character's fighting provess improves during the night.";
		this.m.Icon = "ui/traits/trait_icon_moonkissed.png";
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
				icon = "ui/icons/bravery.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+5[/color] Resolve during Nighttime"
			}
			{
				id = 11,
				type = "text",
				icon = "ui/icons/melee_skill.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+5[/color] Melee Skill during Nighttime"
			}
			{
				id = 12,
				type = "text",
				icon = "ui/icons/regular_damage.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+10%[/color] Melee Damage during Nighttime"
			},
		];
	}


	
	function onUpdate( _properties )
	{
		if (!this.World.getTime().IsDaytime)
		{
			_properties.MeleeSkill += 5;
			_properties.MeleeDamageMult *= 1.1;
			_properties.Bravery +=5;
		}
	}

});

