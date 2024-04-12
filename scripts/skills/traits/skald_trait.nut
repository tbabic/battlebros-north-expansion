this.rally_the_troops <- this.inherit("scripts/skills/skill", {
	m = {},
	function create()
	{
		this.m.ID = "trait.skald";
		this.m.Name = "Skald";
		this.m.Description = "This character's provess in battle inspires nearby allies.";
		this.m.Icon = "ui/perks/perk_42_active.png";
		this.m.Overlay = "perk_42_active";
		this.m.SoundOnUse = [
			"sounds/combat/rally_the_troops_01.wav"
		];
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.Any;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsStacking = false;
		this.m.IsAttack = false;
		this.m.IsVisibleTileNeeded = false;
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 25;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
	}

	function getTooltip()
	{
		local bravery = this.Math.max(0, this.Math.floor(this.getContainer().getActor().getCurrentProperties().getBravery() * 0.4));
		local ret = [
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
				text = "When hitting a target, triggers a morale check to improve closest ally within 4 tiles with a bonus to Resolve of [color=" + this.Const.UI.Color.PositiveValue + "]+" + 5 + "[/color]"
			},
		];

		return ret;
	}
	

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		local myTile = _user.getTile();
		local difficulty = 5;
		local actors = this.Tactical.Entities.getInstancesOfFaction(_user.getFaction());
		
		local closestActor = null;
		local closestDistance = 4;
		foreach( a in actors )
		{
			if (a.getID() == _user.getID())
			{
				continue;
			}
			local distance = myTile.getDistanceTo(a.getTile());
			if ( distance > closestDistance && !a.getFlags().has("NEM_skald_effect"))
			{
				continue;
			}
			
			closestActor = a;
			closestDistance = distance;
		}
		if (closestActor == null)
		{
			return;
		}

		local morale = a.getMoraleState();
		local attempts = this.Const.MoraleState.Confident - this.Math.max(morale, this.Const.MoraleState.Breaking);
		for (local i = 0; i < attempts; i++)
		{
			if (a.getMoraleState() == this.Const.MoraleState.Fleeing)
			{
				a.checkMorale(this.Const.MoraleState.Wavering - this.Const.MoraleState.Fleeing, difficulty, this.Const.MoraleCheckType.Default, "status_effect_56");
			}
			else
			{
				a.checkMorale(1, difficulty, this.Const.MoraleCheckType.Default, "status_effect_56");
			}
		}
		
		if (morale != a.getMoraleState())
		{
			a.getFlags().add("NEM_skald_effect");
		}
	}
	
	
	function onTurnStart()
	{
		this.reset();
	}
	
	function onTurnEnd()
	{
		this.reset();
	}
	
	function onCombatFinished()
	{
		this.reset();
	}
	
	function reset()
	{
		local actor = this.getContainer().getActor();
		local allies = this.Tactical.Entities.getInstancesOfFaction(actor.getFaction());

		foreach( ally in allies )
		{
			ally.getFlags().remove("NEM_skald_effect");
		}
	}

});

