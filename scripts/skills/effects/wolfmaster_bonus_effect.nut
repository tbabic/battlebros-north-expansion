this.wolfmaster_bonus_effect <- this.inherit("scripts/skills/skill", {
	m = {
		Difference = 0
	},
	function create()
	{
		this.m.ID = "effects.wolfmaster_bonus";
		this.m.Name = "Wolf & Master";
		this.m.Description = "Wolf & Master are fighting together increasing their effectiveness.";
		this.m.Icon = "skills/status_effect_06.png";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.VeryLast;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsHidden = true;
	}

	function getTooltip()
	{
		local bonus = this.m.Difference;
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
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + bonus + "[/color] Resolve"
			}
		];
	}
	
	function checkConditions()
	{
		logInfo("check conditions");
		local actor = this.getContainer().getActor();
		if (!actor.isPlacedOnMap())
		{
			logInfo("not on map");
			return false;
		}
		
		local collar = actor.m.Item;
		if (collar == null)
		{
			logInfo("no collar");
			return false;
		}
		local ally = collar.getContainer().getActor();
		if (ally == null || ally.isNull() || !ally.isAlive())
		{
			logInfo("no ally");
			return false;
		}
		local myTile = actor.getTile();
		local allyDistance = ally.getTile().getDistanceTo(myTile);
		logInfo("ally: " + ally.getName() + " dist:"  + allyDistance);
		ally.getSkills().update();
		if (ally.getSkills().hasSkill("trait.wolfmaster") && allyDistance == 1)
		{
			return true;
		}
		return false;
	}

	function processBonus( _properties )
	{
		this.m.IsHidden = true;
		if(this.checkConditions())
		{
			this.m.IsHidden = false;
			_properties.MeleeSkill += 5;
			_properties.MeleeDefense += 5;
			//add bonuse to wolf
		}
	}

	function onUpdate( _properties )
	{
		logInfo("update direwolf");
		this.processBonus(_properties);
	}

	function onCombatFinished()
	{

	}

});

