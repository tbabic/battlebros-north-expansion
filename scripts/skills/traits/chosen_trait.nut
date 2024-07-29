this.chosen_trait <- this.inherit("scripts/skills/traits/character_trait", {
	m = {
		Value = 0
	},
	function create()
	{
		logInfo("creating chosen trait");
		this.character_trait.create();
		this.m.ID = "trait.chosen";
		this.m.Name = "Chosen";
		this.m.Icon = "ui/traits/trait_icon_chosen.png";
		this.m.Description = "An elite barbarian warrior, the heavier armor he wears the more confident and better fighter he is.";
		this.m.Excluded = [
			"trait.thrall",
		];

	}

	function getTooltip()
	{
		local t = [
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
				icon = "ui/icons/special.png",
				text = "The character receives a penalty if lightly armored or bonus if heavily armored."
			}
		];
		
		if (this.m.Value < 0)
		{
			t.push(::NorthMod.Utils.createBonusSkillTooltip("MeleeSkill", this.m.Value, 11));
			t.push(::NorthMod.Utils.createBonusSkillTooltip("MeleeDefense", this.m.Value, 12));
			t.push(::NorthMod.Utils.createBonusSkillTooltip("Bravery", this.m.Value, 13));
			t.push(::NorthMod.Utils.createBonusSkillTooltip("Stamina", this.m.Value, 14));
		}
		return t;
	}
	

	function onUpdate( _properties )
	{
		local armor = 0;
		local body = this.getContainer().getActor().getItems().getItemAtSlot(this.Const.ItemSlot.Body);
		local head = this.getContainer().getActor().getItems().getItemAtSlot(this.Const.ItemSlot.Head);
		
		
		if (body != null)
		{
			armor += body.getArmorMax();
		}

		if (head != null)
		{
			armor += head.getArmorMax();
		}
		
		if (armor < 300)
		{
			this.m.Value = this.Math.max(-5, (armor - 300) / 10);
		}
		else
		{
			this.m.Value = this.Math.min(-5, (armor - 300) / 50);
		}
		this.m.Value = this.Math.round(this.m.Value);
		
		
		_properties.MeleeSkill += this.m.Value;
		_properties.MeleeDefense += this.m.Value;
		_properties.Bravery += this.m.Value;
		_properties.Stamina += this.m.Value;
	}
	
	
	function onAdded()
	{
		local background = this.getContainer().getSkillByID("background.barbarian");
		if (this.m.IsNew)
		{
			local actor = this.getContainer().getActor();
			actor.setTitle(::NorthMod.Utils.barbarianTitle());
			
			background.m.Level = 1;
			
			background.m.ExcludedTalents = [
				this.Const.Attributes.Initiative,
				this.Const.Attributes.RangedSkill
			];
			
			actor.m.Level = this.m.Math.rand(4,5);
			actor.m.PerkPoints = actor.m.Level - 1;
			actor.m.LevelUps = actor.m.Level - 1;
			actor.m.Level = actor.m.Level;
			actor.m.XP = this.Const.LevelXP[actor.m.Level - 1];
		}
		
		background.m.DailyCost = 30;
		this.character_trait.onAdded();
	}
	

});

