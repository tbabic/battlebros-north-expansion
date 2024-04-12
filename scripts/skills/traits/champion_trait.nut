this.champion_trait <- this.inherit("scripts/skills/traits/character_trait", {
	m = {
		Duel = false
	},
	function create()
	{
		logInfo("creating champion trait");
		this.character_trait.create();
		this.m.ID = "trait.champion";
		this.m.Name = "Champion";
		this.m.Icon = "ui/traits/trait_icon_champion.png";
		this.m.Description = "This character is a known champion and master of duels and single combat";
		this.m.Type = this.m.Type;
		this.m.Titles = [];
		this.m.Excluded = [];
		
		
		foreach (t in this.Const.CharacterTraits)
		{
			this.m.Excluded.push(t[0]);
		}
		this.m.Excluded.push("trait.destined");
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
				icon = "ui/icons/melee_skill.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+5[/color] Melee Skill"
			},
			{
				id = 11,
				type = "text",
				icon = "ui/icons/melee_skill.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+10[/color] Melee Skill when in duel"
			}
		];
	}
	
	function onCombatStarted(  )
	{
		local actors = this.Tactical.Entities.getAllInstances();
		if (actors.len() <= 2)
		{
			this.m.Duel = true;
		}
	}

	function onUpdate( _properties )
	{
		if (this.m.Duel)
		{
			_properties.MeleeSkill += 10;
		}
		else
		{
			_properties.MeleeSkill += 5;
		}

	}
	
	function onCombatFinished()
	{
		this.m.Duel = false;
	}

});

