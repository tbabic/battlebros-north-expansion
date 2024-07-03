this.nem_unwelcome_situation <- this.inherit("scripts/entity/world/settlements/situations/situation", {
	m = {},
	function create()
	{
		this.situation.create();
		this.m.ID = "situation.nem_unwelcome";
		this.m.Name = "Not Welcome";
		this.m.Description = "Due to your actions, you are not considered welcome among these barbarians. People are unwilling to work or trade with you.";
		this.m.Icon = "skills/status_effect_103.png";
		this.m.Rumors = [
		];
	}

	function getAddedString( _s )
	{
		return _s + " now has " + this.m.Name;
	}

	function getRemovedString( _s )
	{
		return _s + " no longer has " + this.m.Name;
	}

	function onAdded( _settlement )
	{
		_settlement.resetShop();
	}

	function onUpdate( _modifiers )
	{
		_modifiers.BuyPriceMult *= 2;
		_modifiers.SellPriceMult *= 0.5;
		_modifiers.RarityMult *= 0.75;
		_modifiers.RecruitsMult *= 0.5;
	}

});

