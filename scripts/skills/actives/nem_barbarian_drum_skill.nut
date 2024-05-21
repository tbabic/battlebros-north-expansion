this.nem_barbarian_drum_skill <- this.inherit("scripts/skills/skill", {
	m = {
		FatigueReduction = 10
	},
	function create()
	{
		this.m.ID = "actives.nem_barbarian_drum";
		this.m.Name = "Drums of War";
		this.m.Description = "Drums of War will reduce the fatigue of all allies by " + this.m.FatigueReduction;
		this.m.Icon = "skills/wardrum.png";
		this.m.IconDisabled = "skills/wardrum_sw.png";
		this.m.Overlay = "active_163";
		this.m.SoundOnUse = [
			"sounds/enemies/dlc4/wardrums_01.wav",
			"sounds/enemies/dlc4/wardrums_02.wav",
			"sounds/enemies/dlc4/wardrums_03.wav"
		];
		this.m.SoundVolume = 1.5;
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.Any;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsStacking = false;
		this.m.IsAttack = false;
		this.m.IsVisibleTileNeeded = false;
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 15;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
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
				id = 3,
				type = "text",
				text = this.getCostString()
			}
		];
	}

	function onUse( _user, _targetTile )
	{
		local myTile = _user.getTile();
		this.logInfo("drums: " + _user.getName() + " / " + _user.getID())
		local actors = this.Tactical.Entities.getInstancesOfFaction(_user.getFaction());

		foreach( a in actors )
		{
			this.logInfo("drums: " + a.getName() + " / " + a.getID());
			if (a.getFatigue() == 0)
			{
				continue;
			}
			if (a.getFaction() == _user.getFaction())
			{
				a.setFatigue(this.Math.max(0, a.getFatigue() - this.m.FatigueReduction));
				this.spawnIcon(this.m.Overlay, a.getTile());
			}
		}
		return true;
	}

});

