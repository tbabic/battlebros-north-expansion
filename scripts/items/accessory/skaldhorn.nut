this.skaldhorn <- this.inherit("scripts/items/accessory/accessory", {
	m = {},
	
	function create()
	{
		this.accessory.create();
		this.m.ID = "accessory.skaldhorn";
		this.m.Name = "War Horn";
		this.m.Description = "A war horn fashioned of unhold bones worn by your second-in-command on the battlefield.";
		this.m.SlotType = this.Const.ItemSlot.Accessory;
		this.m.IsDroppedAsLoot = true;
		this.m.ShowOnCharacter = false;
		this.m.IconLarge = "";
		this.m.Icon = "accessory/skald_horn.png";
		this.m.Sprite = "";
		this.m.Value = 1000;
	}

	function getTooltip()
	{
		local result = this.accessory.getTooltip();
		result.push({
			id = 10,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Allies at a range of 4 tiles or less receive [color=" + this.Const.UI.Color.PositiveValue + "]10%[/color] of the Resolve of the character wearing this horn as a bonus, up to a maximum of the standard bearer\'s Resolve."
		});
		return result;
	}
	
	function getBuyPrice()
	{
		return 1000000;
	}
	
	function onMovementFinished()
	{
		local actor = this.getContainer().getActor();
		local allies = this.Tactical.Entities.getInstancesOfFaction(actor.getFaction());

		foreach( ally in allies )
		{
			if (ally.getID() != actor.getID())
			{
				ally.getSkills().update();
			}
		}
	}
	
	
	function onCombatStarted()
	{
		//todo add skald effect on all alliess
		local actor = this.getContainer().getActor();
		local allies = this.Tactical.Entities.getInstancesOfFaction(actor.getFaction());

		foreach( ally in allies )
		{
			if (!ally.getSkills().hasSkill("effects.skald_horn"))
			{
				ally.getSkills().add(this.new("scripts/skills/effects/skald_horn_effect"));	
			}
			
		}
		
	}

	function onCombatFinished()
	{
		local actor = this.getContainer().getActor();
		if(this.getContainer() == null || actor == null)
		{
			return;
		}
		local allies = this.Tactical.Entities.getInstancesOfFaction(actor.getFaction());

		foreach( ally in allies )
		{
			ally.getSkills().removeByID("effects.skald_horn");
		}
	}

});

