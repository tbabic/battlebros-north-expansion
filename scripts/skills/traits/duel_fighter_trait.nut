this.duel_fighter_trait <- this.inherit("scripts/skills/traits/character_trait", {
	m = {
		Bonus = 0
	},
	function create()
	{
		this.character_trait.create();
		this.m.ID = "trait.duel_fighter";
		this.m.Name = "Duel Fighter";
		this.m.Icon = "ui/traits/trait_duel_fighter.png";
		this.m.Description = "This character has experience fighting in single combat which makes him tougher";
	}
	
	function updateStatistics(_championLevel)
	{
		local flags = this.getContainer().getActor().getFlags();
		flags.increment("Nem_DuelFights");
		if(_championLevel ==1)
		{
			flags.increment("Nem_DuelThralls");
		}
		if(_championLevel ==2)
		{
			flags.increment("Nem_DuelReavers");
		}
		if(_championLevel ==3)
		{
			flags.increment("Nem_DuelChosen");
		}
		if(_championLevel ==4)
		{
			flags.increment("Nem_DuelChampion");
		}
		this.updateBonus();
	}

	function getTooltip()
	{
		local won = this.getContainer().getActor().getFlags().getAsInt("Nem_DuelFights");

		local flags = this.getContainer().getActor().getFlags();
		
		local tooltip = [
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
		]
		
		if(flags.getAsInt("Nem_DuelThralls") > 0)
		{
			tooltip.push({
				id = 10,
				type = "text",
				icon = "ui/icons/damage_dealt.png",
				text = "Defeated a Thrall"
			})
		}
		if(flags.getAsInt("Nem_DuelReavers") > 0)
		{
			tooltip.push({
				id = 10,
				type = "text",
				icon = "ui/icons/damage_dealt.png",
				text = "Defeated a Reaver"
			})
		}
		if(flags.getAsInt("Nem_DuelChosen") > 0)
		{
			tooltip.push({
				id = 10,
				type = "text",
				icon = "ui/icons/damage_dealt.png",
				text = "Defeated a Chosen"
			})
		}
		if(flags.getAsInt("Nem_DuelChampion") > 0)
		{
			tooltip.push({
				id = 10,
				type = "text",
				icon = "ui/icons/damage_dealt.png",
				text = "Defeated a Champion"
			})
		}
		if (flags.getAsInt("Nem_DuelFights") >= 5)
		{
			tooltip.push({
				id = 10,
				type = "text",
				icon = "ui/icons/damage_dealt.png",
				text = "Won five or more duels"
			})
		}
		if (this.m.Bonus > 0)
		{
			tooltip.push({
				id = 11,
				type = "text",
				icon = "ui/icons/health.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + this.m.Bonus + "[/color] Hitpoints"
			})
		}
		return tooltip;
	}
	
	
		
	function onUpdate( _properties )
	{
		this.updateBonus();
		_properties.Hitpoints += this.m.Bonus;
	}
	
	function updateBonus()
	{
		this.m.Bonus = 0;
		local flags = this.getContainer().getActor().getFlags();
		if(flags.getAsInt("Nem_DuelThralls") > 0)
		{
			this.m.Bonus++;
		}
		if(flags.getAsInt("Nem_DuelReavers") > 0)
		{
			this.m.Bonus++;
		}
		if(flags.getAsInt("Nem_DuelChosen") > 0)
		{
			this.m.Bonus++;
		}
		if(flags.getAsInt("Nem_DuelChampion") > 0)
		{
			this.m.Bonus++;
		}
		if (flags.getAsInt("Nem_DuelFights") >= 5)
		{
			this.m.Bonus++;
		}
	}

});

