this.shieldmaster_trait <- this.inherit("scripts/skills/traits/character_trait", {
	m = {},
	function create()
	{
		logInfo("creating shieldmaster trait");
		this.character_trait.create();
		this.m.ID = "trait.shieldmaster";
		this.m.Name = "Shieldmaster";
		this.m.Icon = "ui/traits/trait_icon_shieldmaster.png";
		this.m.Description = "This character is a master of fighting with a shield offensively and defensively.";
		this.m.Type = this.m.Type;
		this.m.Titles = [];
		this.m.Excluded = [];
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
				id = 11,
				type = "text",
				icon = "ui/icons/regular_damage.png",
				text = "When wearing a shield, [color=" + this.Const.UI.Color.PositiveValue + "]+10%[/color] Melee Damage"
			},
		];
	}

	function onUpdate( _properties )
	{
		local actor = this.getContainer().getActor();
		local items = actor.getItems();
		offhand = items.getItemAtSlot(this.Const.ItemSlot.Offhand);
		if ( offhand.isItemType(this.Const.Items.ItemType.Shield))
		{
			_properties.MeleeDamageMult *= 1.1;
		}
			
	}

});

