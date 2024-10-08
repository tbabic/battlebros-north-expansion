this.thrall_trait <- this.inherit("scripts/skills/traits/character_trait", {
	m = {
		Value = 0,
		MaxLevel = 5
	},
	function create()
	{
		logInfo("creating thrall trait");
		this.character_trait.create();
		this.m.ID = "trait.thrall";
		this.m.Name = "Thrall";
		this.m.Icon = "ui/traits/trait_icon_thrall.png";
		this.m.Description = "This character is a thrall and is not accustomed to wearing heavy armor.";
		this.m.Excluded = [
			"trait.chosen",
			"trait.greedy"
		];
		this.m.Order = this.Const.SkillOrder.Trait;

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
				id = 9,
				type = "text",
				icon = "ui/icons/special.png",
				text = "The character receives a penalty equal to armor fatigue."
			}
			{
				id = 10,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Can only reach fifth level."
			}
		];
		
		if (this.m.Value < 0)
		{
			t.push(::NorthMod.Utils.createBonusSkillTooltip("MeleeSkill", this.m.Value, 11));
			t.push(::NorthMod.Utils.createBonusSkillTooltip("MeleeDefense", this.m.Value, 12));
			t.push(::NorthMod.Utils.createBonusSkillTooltip("RangedSkill", this.m.Value, 13));
			t.push(::NorthMod.Utils.createBonusSkillTooltip("RangedDefense", this.m.Value, 14));
			t.push(::NorthMod.Utils.createBonusSkillTooltip("Bravery", this.m.Value, 15));
		}
		return t;
	}

	function onUpdate( _properties )
	{
		
		if(this.getContainer() == null || this.getContainer().getActor() == null)
		{
			return;
		}
		local fat = 0;
		local body = this.getContainer().getActor().getItems().getItemAtSlot(this.Const.ItemSlot.Body);
		local head = this.getContainer().getActor().getItems().getItemAtSlot(this.Const.ItemSlot.Head);
		
		if (body != null)
		{
			fat += body.getStaminaModifier();
		}

		if (head != null)
		{
			fat += head.getStaminaModifier();
		}
		this.m.Value = fat;
		
		if (this.m.Value < 0)
		{
			_properties.MeleeSkill += this.m.Value;
			_properties.MeleeDefense += this.m.Value;
			_properties.RangedSkill += this.m.Value;
			_properties.RangedDefense += this.m.Value;
			_properties.Bravery += this.m.Value;
		}
		
		if(this.getContainer().getActor().getLevel() >= this.m.MaxLevel)
		{
			_properties.XPGainMult *= 0.0;
		}
		
	}
	
	
	function onAdded()
	{
		local background = this.getContainer().getSkillByID("background.barbarian");
		if (this.m.IsNew)
		{
			local actor = this.getContainer().getActor();
			actor.setTitle("");
			background.m.Titles = [];
			background.m.HairColors = this.Const.HairColors.Young;
			background.m.Level = 1;
			background.m.HiringCost = this.Math.rand(10, 15)*10;
			
			actor.m.PerkPoints = 0;
			actor.m.LevelUps = 0;
			actor.m.Level = 1;
			actor.m.XP = 0;
		}
		
		background.m.DailyCost = 0;
		this.character_trait.onAdded();
	}
	
	function onRemoved()
	{
		if(this.getContainer() == null)
		{
			return;
		}
		local background = this.getContainer().getSkillByID("background.barbarian");
		if(background == null)
		{
			return;
		}
		background.m.DailyCost = 20;
	}
	
	function onCombatFinished()
	{
		if(this.getContainer() == null || this.getContainer().getActor() == null)
		{
			return;
		}
		local actor = this.getContainer().getActor();
		if( actor.m.XP > this.Const.LevelXP[this.m.MaxLevel-1])
		{
			actor.m.XP = this.Const.LevelXP[this.m.MaxLevel-1];
		}
	}

});

