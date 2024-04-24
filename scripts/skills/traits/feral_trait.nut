this.feral_trait <- this.inherit("scripts/skills/traits/character_trait", {
	m = {},
	function create()
	{
		this.character_trait.create();
		this.m.ID = "trait.feral";
		this.m.Name = "Feral";
		this.m.Icon = "ui/traits/trait_icon_feral.png";
		this.m.Description = "This character is feral and ferocious fighter like a wild beast. When unencumbered by armor he gains bonuses that rise the more wounded he is. When close to death he can will not be stopped by bleeding or injuries.";
		this.m.Titles = [
			"the Mad",
			"the Odd",
			"the Fearless"
		];
		this.m.Excluded = [
			"trait.weasel",
			"trait.hesitant",
			"trait.dastard",
			"trait.fainthearted",
			"trait.craven",
			"trait.survivor"
		];
		
		
		this.m.Ferocity <- {
			StartingHP = null,
			Combat = false,
			IsHit = false,
			Active = false,
			Regeneration = 0,
			DamageReduction = 0,
			DamageBonus = 0,
			FatigueRecovery = 0,
			SkillBonus = 0,
			Unstoppable = false,
			Level = 0,
			
		};
		
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
			}];
			
		if (!this.m.Ferocity.Active)
		{
			return t;
		}
		
		t.push({
			id = 10,
			type = "text",
			icon = "ui/icons/morale.png",
			text = "No morale check triggered upon losing hitpoints"
		});
	
		if(this.m.Ferocity.Regeneration > 0)
		{
			t.push({
				id = 10,
				type = "text",
				icon = "ui/icons/health.png",
				text = "Heals [color=" + this.Const.UI.Color.PositiveValue + "]" + this.m.Ferocity.Regeneration + "[/color] hitpoints each turn"
			});
		}
		
		if(this.m.Ferocity.DamageReduction > 0)
		{
			t.push({
				id = 10,
				type = "text",
				icon = "ui/icons/melee_skill.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+"+ this.m.Ferocity.DamageReduction + "%[/color] Damage Reduction"
			});
		}
		
		if(this.m.Ferocity.DamageBonus > 0)
		{
			t.push({
				id = 10,
				type = "text",
				icon = "ui/icons/regular_damage.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+"+ this.m.Ferocity.DamageBonus + "%[/color] Melee Damage"
			});
		}
		
		
		if(this.m.Ferocity.FatigueRecovery > 0)
		{
			t.push({
				id = 10,
				type = "text",
				icon = "ui/icons/fatigue.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+"+ this.m.Ferocity.FatigueRecovery + "[/color] Fatigue Recovery per turn"
			});
		}
		
		if(this.m.Ferocity.SkillBonus > 0)
		{
			t.push({
				id = 10,
				type = "text",
				icon = "ui/icons/plus.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+"+ this.m.Ferocity.SkillBonus + "[/color] Melee Skill, Melee Defense, Ranged Skill and Ranged Defense"
			});
		}
		
		if(this.m.Ferocity.Unstoppable)
		{
			t.push({
				id = 10,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Unstoppable. Not affected by injuries, bleeding, poison, knock, stun, grab, daze and overwhelm"
			});
		}
		
		return t;
		
	}
	
	function onCombatStarted()
	{
		local actor = this.getContainer().getActor();
		this.m.Ferocity.StartingHP = actor.getHitpoints();
		this.m.Ferocity.Level = 0;
		this.m.Ferocity.Combat = true;
	}

	
	function onCombatFinished()
	{
		this.m.Ferocity.Level = 0;
		this.m.Ferocity.Combat = false;
		this.m.Ferocity.IsHit = false;
		this.m.Ferocity.Active = false;
		this.m.Ferocity.Unstoppable = false;
	}
	
	function onDamageReceived( _attacker, _damageHitpoints, _damageArmor )
	{
		this.m.Ferocity.IsHit = true;
	}

	
	function onTurnStart()
	{
		if(!this.isFerocityActive())
		{
			return;
		}
		
		local actor = this.getContainer().getActor();
		local healthMissing = this.m.Ferocity.StartingHP - actor.getHitpoints();
		local healthAdded = this.Math.min(healthMissing, this.m.Ferocity.Regeneration);
		
		if (healthAdded <= 0)
		{
			return;
		}

		actor.setHitpoints(actor.getHitpoints() + healthAdded);
		actor.setDirty(true);

		if (!actor.isHiddenToPlayer())
		{
			this.Tactical.spawnIconEffect("status_effect_79", actor.getTile(), this.Const.Tactical.Settings.SkillIconOffsetX, this.Const.Tactical.Settings.SkillIconOffsetY, this.Const.Tactical.Settings.SkillIconScale, this.Const.Tactical.Settings.SkillIconFadeInDuration, this.Const.Tactical.Settings.SkillIconStayDuration, this.Const.Tactical.Settings.SkillIconFadeOutDuration, this.Const.Tactical.Settings.SkillIconMovement);
			this.Sound.play("sounds/enemies/unhold_regenerate_01.wav", this.Const.Sound.Volume.RacialEffect * 1.25, actor.getPos());
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(actor) + " heals for " + healthAdded + " points");
		}
		this.updateRegeneration();
		
		local threshold = this.threshold();
		if (this.m.Ferocity.Unstoppable)
		{
			actor.setMoraleState(this.Const.MoraleState.Confident);
			while (actor.getSkills().hasSkill("effects.goblin_poison"))
			{
				actor.getSkills().removeByID("effects.goblin_poison");
			}

			while (actor.getSkills().hasSkill("effects.spider_poison"))
			{
				actor.getSkills().removeByID("effects.spider_poison");
			}
		}
		
	}
	
	
	function onUpdate( _properties )
	{
		if(!this.isFerocityActive())
		{
			return;
		}
		
		local threshold = this.updateFerocity();
		_properties.IsAffectedByLosingHitpoints = false;
		
		_properties.DamageReceivedRegularMult *= 1.0 - (0.01 * this.m.Ferocity.DamageReduction);
		_properties.MeleeSkill += this.m.Ferocity.SkillBonus;
		_properties.MeleeDefense += this.m.Ferocity.SkillBonus;
		_properties.RangedSkill += this.m.Ferocity.SkillBonus;
		_properties.RangedDefense += this.m.Ferocity.SkillBonus;
		_properties.Bravery += this.m.Ferocity.SkillBonus;
		_properties.MeleeDamageMult *= 0.01 * this.m.Ferocity.DamageBonus + 1.0;
		_properties.FatigueRecoveryRate += this.m.Ferocity.FatigueRecovery;
		
		if (this.m.Ferocity.Unstoppable)
		{
			this.getContainer().removeByType(this.Const.SkillType.DamageOverTime);
			_properties.IsAffectedByInjuries = false;
			_properties.DamageReceivedTotalMult *= 0.5;
			_properties.IsImmuneToStun = true;
			_properties.IsImmuneToKnockBackAndGrab = true;
			_properties.IsImmuneToDaze = true;
			_properties.IsImmuneToOverwhelm = true;
			_properties.IsImmuneToPoison = true;
			
		}
		
	}
	
	
	function updateFerocity()
	{	
		local threshold = this.threshold();
		this.updateRegeneration(threshold);
		this.updateSkillBonus(threshold);
		this.updateDamageBonus(threshold);
		this.updateDamageReduction(threshold);
		this.updateFatigueRecovery(threshold);
		
		if(threshold == 3)
		{
			this.m.Ferocity.Unstoppable = true;
		}
		else
		{
			this.m.Ferocity.Unstoppable = false;
		}
		
		return threshold;
	}
	
	function isFerocityActive()
	{
		local fat = 0;
		local body = this.getContainer().getActor().getItems().getItemAtSlot(this.Const.ItemSlot.Body);
		local head = this.getContainer().getActor().getItems().getItemAtSlot(this.Const.ItemSlot.Head);
		
		if (body == null && head == null)
		{
			this.m.Ferocity.Active = true;
			return true;
		}
		
		if (body != null)
		{
			fat = fat + body.getStaminaModifier();
		}

		if (head != null)
		{
			fat = fat + head.getStaminaModifier();
		}
		if (fat == 0)
		{
			this.m.Ferocity.Active = true;
			return true;
		}
		
		this.m.Ferocity.Active = false;
		return false;
	}
		
	
	function updateRegeneration(_threshold = null)
	{
		local threshold = _threshold;
		if (threshold == null)
		{
			threshold = this.threshold();
		}
		
		if (threshold == 0)
		{
			this.m.Ferocity.Regeneration = 0;
		}
		
		if (threshold == 1)
		{
			this.m.Ferocity.Regeneration = 5;
		}
		
		if (threshold == 2)
		{
			this.m.Ferocity.Regeneration = 10;
		}
		
		if (threshold == 3)
		{
			this.m.Ferocity.Regeneration = 15;
		}
	}
	
	function updateSkillBonus(_threshold = null)
	{
		local threshold = _threshold;
		if (threshold == null)
		{
			threshold = this.threshold();
		}
		
		this.m.Ferocity.SkillBonus = threshold*5;
	}
	
	function updateDamageBonus(_threshold = null)
	{
		local threshold = _threshold;
		if (threshold == null)
		{
			threshold = this.threshold();
		}
		
		this.m.Ferocity.DamageBonus = 5 * threshold;
	}
	
	function updateDamageReduction(_threshold = null)
	{
		local threshold = _threshold;
		if (threshold == null)
		{
			threshold = this.threshold();
		}
		local baseDR = 20;
		local bonusDR = 5 * threshold ;
		this.m.Ferocity.DamageReduction = baseDR + bonusDR;
	}
	
	function updateFatigueRecovery(_threshold = null)
	{
		local threshold = _threshold;
		if (threshold == null)
		{
			threshold = this.threshold();
		}
		
		if (threshold == 0)
		{
			this.m.Ferocity.FatigueRecovery = 0;
		}
		
		if (threshold == 1)
		{
			this.m.Ferocity.FatigueRecovery = 1;
		}
		
		if (threshold == 2)
		{
			this.m.Ferocity.FatigueRecovery = 3;
		}
		
		if (threshold == 3)
		{
			this.m.Ferocity.FatigueRecovery = 5;
		}
	}
	
	function threshold()
	{
		local actor = this.getContainer().getActor();
		local currentHP = actor.getHitpoints();
		local maxHP = actor.getHitpointsMax();
		local currentLevel = 0;
		
		local nineLives = actor.getSkills().getSkillByID("perk.nine_lives");
		if (nineLives != null && nineLives.isSpent())
		{
			return 3;
		}
		
		if (!this.m.Ferocity.Combat)
		{
			return 0;
		}
		if (!this.m.Ferocity.IsHit)
		{
			return 0;
		}
		
		if (currentHP <= 0.25 * maxHP)
		{
			currentLevel = 3;
		}
		else if (currentHP <= 0.5* maxHP)
		{
			currentLevel = 2;
		}
		else if (currentHP <= 0.75* maxHP)
		{
			currentLevel = 1;
		}
		
		if (currentLevel == 0)
		{
			this.m.Ferocity.Level = 0;
		}
		
		else if (currentLevel < this.m.Ferocity.Level)
		{
			currentLevel = this.m.Ferocity.Level;
		}
		
		else if (currentLevel > this.m.Ferocity.Level)
		{
			this.m.Ferocity.Level = currentLevel;
		}
		
		return currentLevel;
	}

	
	


});

