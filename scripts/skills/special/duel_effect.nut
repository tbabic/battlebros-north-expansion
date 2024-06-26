this.duel_effect <- this.inherit("scripts/skills/skill", {
	m = {
		SkillsToDisable = [
			"actives.unleash_wardog",
			"actives.unleash_wolf",
			"actives.unleash_direwolf"
		]
	},
	function create()
	{
		this.m.ID = "special.duel";
		this.m.Name = "";
		this.m.Icon = "";
		this.m.Type = this.Const.SkillType.Special;
		this.m.Order = this.Const.SkillOrder.Last;
		this.m.IsActive = false;
		this.m.IsHidden = true;
		this.m.IsSerialized = false;
		this.m.IsRemovedAfterBattle = true;
	}

	function onCombatStarted()
	{
		local actor = this.getContainer().getActor();
		this.logInfo("disable hounds");
		foreach (id in this.m.SkillsToDisable)
		{
			local skill = actor.getSkills().getSkillByID(id);
			if (skill != null)
			{
				skill.m.IsActive = false;
			}
			
		}
		
	}
	
	function onCombatFinished()
	{
		local actor = this.getContainer().getActor();
		this.logInfo("enable hounds");
		if(this.getContainer() != null && actor != null)
		{
			foreach (id in this.m.SkillsToDisable)
			{
				local skill = actor.getSkills().getSkillByID(id);
				if (skill != null)
				{
					skill.m.IsActive = true;
				}
			}
		}
		
		this.removeSelf();
	}

});

