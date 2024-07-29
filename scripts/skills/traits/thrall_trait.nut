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
			_properties.IsAllyXPBlocked = true;
		}
		
	}
	
	
	function onActorKilled( _actor, _tile, _skill )
	{
		this.actor.onActorKilled(_actor, _tile, _skill);

		if(this.getContainer() == null || this.getContainer().getActor() == null)
		{
			return;
		}
		
		if(this.getContainer().getActor().getLevel() < this.m.MaxLevel)
		{
			return;
		}
		if (this.getFaction() != this.Const.Faction.Player)
		{
			return;
		}
		
		local XPgroup = _actor.getXPValue();
		local brothers = this.Tactical.Entities.getInstancesOfFaction(this.Const.Faction.Player);

		foreach( bro in brothers )
		{
			if (bro.getCurrentProperties().IsAllyXPBlocked)
			{
				return;
			}

			bro.addXP(this.Math.max(1, this.Math.floor(XPgroup / brothers.len())));
		}
	
	}
	
	
	function onAdded()
	{
		local background = this.getContainer().getSkillByID("background.barbarian");
		if (this.m.IsNew)
		{
			local actor = this.getContainer().getActor();
			actor.setTitle("");
			
			background.m.HairColors = this.Const.HairColors.Young;
			background.m.Level = 1;
			
			actor.m.PerkPoints = 0;
			actor.m.LevelUps = 0;
			actor.m.Level = 1;
			actor.m.XP = 0;
		}
		
		background.m.DailyCost = 0;
		this.character_trait.onAdded();
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

